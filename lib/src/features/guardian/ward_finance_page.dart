import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import '../../core/auth/auth_models.dart';
import 'invoice_models.dart';

class WardFinancePage extends StatefulWidget {
  const WardFinancePage({super.key, required this.ward});

  final WardView ward;

  @override
  State<WardFinancePage> createState() => _WardFinancePageState();
}

class _WardFinancePageState extends State<WardFinancePage> {
  final _api = AuthApi();
  late Future<List<InvoiceView>> _invoices;

  @override
  void initState() {
    super.initState();
    _invoices = _api.studentInvoices(widget.ward.id);
  }

  void _retry() {
    setState(() => _invoices = _api.studentInvoices(widget.ward.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.ward.firstName} ${widget.ward.lastName} · Fees')),
      body: FutureBuilder<List<InvoiceView>>(
        future: _invoices,
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
                    const Text('Fee information could not be loaded.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _retry, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final invoices = snapshot.data ?? const <InvoiceView>[];
          final outstanding = invoices.fold<double>(
            0,
            (sum, invoice) => sum + (double.tryParse(invoice.outstandingAmount) ?? 0),
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Outstanding balance'),
                      const SizedBox(height: 6),
                      Text(
                        'GH₵ ${outstanding.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text('Payments will become available after the school payment reservation and provider verification flow is enabled.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Invoices', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (invoices.isEmpty)
                const Card(child: ListTile(title: Text('No invoices yet.'))),
              ...invoices.map(
                (invoice) => Card(
                  child: ExpansionTile(
                    title: Text(invoice.invoiceNumber),
                    subtitle: Text('${invoice.status} · issued ${invoice.issuedAt.toLocal().toString().split(' ').first}'),
                    trailing: Text('GH₵ ${invoice.outstandingAmount}'),
                    children: [
                      ListTile(title: const Text('Total'), trailing: Text('GH₵ ${invoice.totalAmount}')),
                      ListTile(title: const Text('Allocated'), trailing: Text('GH₵ ${invoice.amountAllocated}')),
                      if (invoice.dueAt != null)
                        ListTile(
                          title: const Text('Due'),
                          trailing: Text(invoice.dueAt!.toLocal().toString().split(' ').first),
                        ),
                      ...invoice.lines.map(
                        (line) => ListTile(
                          dense: true,
                          title: Text(line.description),
                          trailing: Text('GH₵ ${line.amountDue}'),
                        ),
                      ),
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
