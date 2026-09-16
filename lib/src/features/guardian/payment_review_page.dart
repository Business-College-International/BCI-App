import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import '../../core/auth/auth_models.dart';
import 'invoice_models.dart';
import 'payment_preflight_models.dart';

class PaymentReviewPage extends StatefulWidget {
  const PaymentReviewPage({super.key, required this.ward, required this.invoices});

  final WardView ward;
  final List<InvoiceView> invoices;

  @override
  State<PaymentReviewPage> createState() => _PaymentReviewPageState();
}

class _PaymentReviewPageState extends State<PaymentReviewPage> {
  final _api = AuthApi();
  late Future<PaymentPreflightView> _preflight;

  @override
  void initState() {
    super.initState();
    _preflight = _load();
  }

  Future<PaymentPreflightView> _load() {
    final ids = widget.invoices
        .where((invoice) => invoice.outstandingAmount != '0.00' &&
            (invoice.status == 'OPEN' || invoice.status == 'PARTIALLY_PAID'))
        .map((invoice) => invoice.id)
        .toList(growable: false);
    return _api.paymentPreflight(widget.ward.id, ids);
  }

  void _retry() => setState(() => _preflight = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review school fee payment')),
      body: FutureBuilder<PaymentPreflightView>(
        future: _preflight,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('The payment review could not be prepared.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _retry, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final review = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.ward.firstName} ${widget.ward.lastName}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text('Requested amount: GH₵ ${review.requestedAmount}', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text('Selected outstanding: GH₵ ${review.selectedOutstandingAmount}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Planned allocation', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...review.allocations.map(
                (allocation) => Card(
                  child: ListTile(
                    title: Text(allocation.invoiceNumber),
                    trailing: Text('GH₵ ${allocation.amount}'),
                  ),
                ),
              ),
              if (review.pendingPaymentCount > 0) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: Text('${review.pendingPaymentCount} payment attempt(s) already in progress'),
                    subtitle: Text('Pending amount: GH₵ ${review.pendingPaymentAmount}'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment activation'),
                      const SizedBox(height: 8),
                      Text(review.reservationAvailable
                          ? 'A reservation is available.'
                          : 'Payment initiation is not enabled yet.'),
                      const SizedBox(height: 6),
                      Text(review.reservationReason),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
