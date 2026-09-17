import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_models.dart';
import 'receipt_models.dart';

final wardReceiptsProvider = FutureProvider.autoDispose.family<List<ReceiptView>, String>((ref, studentId) {
  return ref.read(authApiProvider).studentReceipts(studentId);
});

class WardReceiptsPage extends ConsumerWidget {
  const WardReceiptsPage({super.key, required this.ward});

  final WardView ward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(wardReceiptsProvider(ward.id));

    return Scaffold(
      appBar: AppBar(title: Text('${ward.firstName} · Payment history')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(wardReceiptsProvider(ward.id)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            receipts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(child: ListTile(title: Text('Could not load payment history'), subtitle: Text('Pull down to retry.'))),
              data: (items) {
                if (items.isEmpty) {
                  return const Card(child: ListTile(title: Text('No payment history yet'), subtitle: Text('Successful fee payments will appear here once the school records them.')));
                }
                return Column(
                  children: items.map((receipt) => _ReceiptCard(receipt: receipt)).toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.receipt});

  final ReceiptView receipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = receipt.fullyRefunded
        ? 'Fully refunded'
        : receipt.hasRefund
            ? 'Partially refunded'
            : receipt.status == 'REFUNDED'
                ? 'Refunded'
                : 'Paid';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${receipt.currency} ${receipt.netAmount}',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        [
                          receipt.receiptNumber ?? 'Receipt pending',
                          if (receipt.completedAt != null) _formatDate(receipt.completedAt!),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(statusLabel)),
              ],
            ),
            const SizedBox(height: 12),
            _MoneyRow(label: 'Original payment', amount: '${receipt.currency} ${receipt.originalAmount}'),
            if (receipt.hasRefund) ...[
              const SizedBox(height: 4),
              _MoneyRow(label: 'Refunded', amount: '${receipt.currency} ${receipt.refundedAmount}'),
              const SizedBox(height: 4),
              _MoneyRow(label: 'Net settled', amount: '${receipt.currency} ${receipt.netAmount}', emphasize: true),
            ],
            const SizedBox(height: 8),
            if (receipt.provider != null || receipt.providerReference != null)
              Text(
                [
                  if (receipt.provider != null) receipt.provider!,
                  if (receipt.providerReference != null) receipt.providerReference!,
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            if (receipt.allocations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Invoices', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              ...receipt.allocations.map(
                (allocation) => Text(
                  '${allocation.invoiceNumber} · ${receipt.currency} ${allocation.amount}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.amount, this.emphasize = false});

  final String label;
  final String amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(amount, style: style),
      ],
    );
  }
}
