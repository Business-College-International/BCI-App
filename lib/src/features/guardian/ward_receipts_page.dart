import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import 'receipt_models.dart';
import 'ward_models.dart';

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
      appBar: AppBar(title: Text('${ward.firstName} · Receipts')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(wardReceiptsProvider(ward.id)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            receipts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(child: ListTile(title: Text('Could not load receipts'), subtitle: Text('Pull down to retry.'))),
              data: (items) {
                if (items.isEmpty) {
                  return const Card(child: ListTile(title: Text('No receipts yet'), subtitle: Text('Successful payments will appear here once the school records them.')));
                }
                return Column(
                  children: items.map((receipt) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                      title: Text('${receipt.currency} ${receipt.amount}'),
                      subtitle: Text([
                        receipt.receiptNumber ?? 'Receipt pending',
                        receipt.completedAt == null ? '' : _formatDate(receipt.completedAt!),
                        receipt.allocations.map((item) => item.invoiceNumber).join(', '),
                      ].where((text) => text.isNotEmpty).join(' · ')),
                      trailing: receipt.receiptFileUrl == null ? null : const Icon(Icons.file_download_outlined),
                    ),
                  )).toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
