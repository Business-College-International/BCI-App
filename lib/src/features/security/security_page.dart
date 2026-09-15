import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import 'security_api.dart';
import 'security_models.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key, required this.api, required this.authApi});
  final SecurityApi api;
  final AuthApi authApi;

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  late Future<List<SecuritySession>> _sessions;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _sessions = widget.api.sessions();
  }

  void _reload() => setState(() => _sessions = widget.api.sessions());

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmed = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(child: Column(children: [
            TextFormField(controller: current, obscureText: true, decoration: const InputDecoration(labelText: 'Current password'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            TextFormField(controller: next, obscureText: true, decoration: const InputDecoration(labelText: 'New password'), validator: (v) => v == null || v.length < 12 ? 'Use at least 12 characters' : null),
            TextFormField(controller: confirmed, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm new password'), validator: (v) => v != next.text ? 'Passwords do not match' : null),
          ])),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            setState(() => _savingPassword = true);
            try {
              await widget.api.changePassword(currentPassword: current.text, newPassword: next.text);
              if (context.mounted) Navigator.pop(context, true);
            } catch (_) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change failed.')));
            } finally {
              if (mounted) setState(() => _savingPassword = false);
            }
          }, child: _savingPassword ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Change')),
        ],
      ),
    );
    current.dispose(); next.dispose(); confirmed.dispose();
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed. You have been signed out of existing sessions.')));
      await widget.authApi.logout();
    }
  }

  Future<void> _revokeAll() async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Revoke all sessions?'), content: const Text('Every active refresh session for this account will be invalidated.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Revoke all'))]));
    if (ok != true) return;
    await widget.api.revokeAllSessions();
    await widget.authApi.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account security')),
      body: RefreshIndicator(onRefresh: () async => _reload(), child: ListView(padding: const EdgeInsets.all(20), children: [
        Card(child: ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Password'), subtitle: const Text('Change your password. Existing refresh sessions are revoked automatically.'), trailing: FilledButton(onPressed: _savingPassword ? null : _changePassword, child: const Text('Change')))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Expanded(child: Text('Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))), TextButton(onPressed: _revokeAll, child: const Text('Revoke all'))]),
          const SizedBox(height: 8),
          FutureBuilder<List<SecuritySession>>(future: _sessions, builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const Text('Sessions could not be loaded.');
            final sessions = snapshot.data ?? const <SecuritySession>[];
            if (sessions.isEmpty) return const Text('No refresh sessions recorded.');
            return Column(children: sessions.map((session) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(session.revokedAt == null ? Icons.verified_user_outlined : Icons.block_outlined), title: Text(session.revokedAt == null ? 'Active session' : 'Revoked session'), subtitle: Text('Created ${session.createdAt.toLocal()}\nExpires ${session.expiresAt.toLocal()}'), isThreeLine: true, trailing: session.revokedAt == null ? IconButton(onPressed: () async { await widget.api.revokeSession(session.id); _reload(); }, icon: const Icon(Icons.remove_circle_outline)) : null)).toList(growable: false));
          }),
        ]))),
      ])),
    );
  }
}
