import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';

final guardianAnnouncementsProvider = FutureProvider.autoDispose((ref) => ref.read(authApiProvider).announcements());

class GuardianAnnouncementsPage extends ConsumerWidget {
  const GuardianAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(guardianAnnouncementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(guardianAnnouncementsProvider),
        child: announcements.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Announcements could not be loaded.'))]),
          data: (items) => items.isEmpty
              ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('No announcements yet.'))])
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(item.publishedAt == null ? item.audienceType : '${item.audienceType} · ${item.publishedAt}'),
                          const SizedBox(height: 12),
                          Text(item.body),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
