import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import 'notification_models.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.api});

  final AuthApi api;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationView>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = widget.api.notifications();
    setState(() {});
  }

  Future<void> _markAllRead() async {
    await widget.api.markAllNotificationsRead();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('Mark all read')),
        ],
      ),
      body: FutureBuilder<List<NotificationView>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Notifications could not be loaded: ${snapshot.error}'));
          final items = snapshot.data ?? const <NotificationView>[];
          if (items.isEmpty) return const Center(child: Text('No notifications yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.title, style: TextStyle(fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(item.body),
                  isThreeLine: true,
                  trailing: item.isRead ? null : const Icon(Icons.mark_email_unread_outlined),
                  onTap: item.isRead ? null : () async {
                    await widget.api.markNotificationRead(item.id);
                    _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
