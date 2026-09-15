import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';

final guardianStationeryProvider = FutureProvider.autoDispose((ref) => ref.read(authApiProvider).stationeryCatalog());

class GuardianStationeryPage extends ConsumerWidget {
  const GuardianStationeryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(guardianStationeryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stationery store')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(guardianStationeryProvider),
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('The stationery catalog could not be loaded.'))]),
          data: (items) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.sku} · Stock ${item.stockQty}'),
                  trailing: Text('GHS ${item.price}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
