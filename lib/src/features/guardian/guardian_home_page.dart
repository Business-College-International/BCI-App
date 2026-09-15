import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import 'ward_academic_page.dart';

class GuardianHomePage extends ConsumerWidget {
  const GuardianHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final wards = ref.watch(wardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BCI Guardian Portal'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(wardsProvider),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome${user == null || user.firstName.isEmpty ? '' : ', ${user.firstName}'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text('Your BCI-connected wards and the permissions available for each relationship.'),
            const SizedBox(height: 20),
            wards.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Could not load wards'),
                  subtitle: const Text('Pull down to retry the authoritative school record.'),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Card(
                    child: ListTile(
                      title: Text('No wards linked yet'),
                      subtitle: Text('The school office will link your ward to your guardian account.'),
                    ),
                  );
                }

                return Column(
                  children: items.map((ward) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(child: Text(ward.firstName.isEmpty ? '?' : ward.firstName[0])),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${ward.firstName} ${ward.lastName}',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text('${ward.relationship} · ${ward.status}'),
                                    ],
                                  ),
                                ),
                                if (ward.isPrimaryContact) const Chip(label: Text('Primary')),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  avatar: Icon(
                                    ward.canViewAcademic ? Icons.school : Icons.school_outlined,
                                    size: 16,
                                  ),
                                  label: Text(ward.canViewAcademic ? 'Academic access' : 'Academic restricted'),
                                ),
                                Chip(
                                  avatar: Icon(
                                    ward.canPayFees ? Icons.payments_outlined : Icons.block,
                                    size: 16,
                                  ),
                                  label: Text(ward.canPayFees ? 'Payments enabled' : 'Payments restricted'),
                                ),
                                Chip(
                                  avatar: Icon(
                                    ward.canManageWallet ? Icons.account_balance_wallet_outlined : Icons.block,
                                    size: 16,
                                  ),
                                  label: Text(ward.canManageWallet ? 'Wallet enabled' : 'Wallet restricted'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (ward.canViewAcademic)
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => WardAcademicPage(ward: ward)),
                                ),
                                icon: const Icon(Icons.school_outlined),
                                label: const Text('View academic results'),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
