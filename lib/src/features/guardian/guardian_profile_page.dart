import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_api.dart';
import 'guardian_profile_models.dart';

class GuardianProfilePage extends ConsumerStatefulWidget {
  const GuardianProfilePage({super.key});

  @override
  ConsumerState<GuardianProfilePage> createState() => _GuardianProfilePageState();
}

class _GuardianProfilePageState extends ConsumerState<GuardianProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _address;
  late final TextEditingController _occupation;
  late final TextEditingController _hometown;
  late final TextEditingController _region;
  GuardianProfileView? _profile;
  bool _loading = true;
  bool _saving = false;
  bool _preferredSms = true;
  bool _preferredPush = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _address = TextEditingController();
    _occupation = TextEditingController();
    _hometown = TextEditingController();
    _region = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _occupation.dispose();
    _hometown.dispose();
    _region.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await ref.read(authApiProvider).guardianProfile();
      _apply(profile);
    } catch (_) {
      if (mounted) setState(() => _error = 'Guardian profile could not be loaded.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply(GuardianProfileView profile) {
    _profile = profile;
    _firstName.text = profile.firstName;
    _lastName.text = profile.lastName;
    _address.text = profile.address ?? '';
    _occupation.text = profile.occupation ?? '';
    _hometown.text = profile.hometown ?? '';
    _region.text = profile.region ?? '';
    _preferredSms = profile.preferredSms;
    _preferredPush = profile.preferredPush;
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      final profile = await ref.read(authApiProvider).updateGuardianProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        occupation: _occupation.text.trim().isEmpty ? null : _occupation.text.trim(),
        hometown: _hometown.text.trim().isEmpty ? null : _hometown.text.trim(),
        region: _region.text.trim().isEmpty ? null : _region.text.trim(),
        preferredSms: _preferredSms,
        preferredPush: _preferredPush,
      );
      _apply(profile);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } catch (_) {
      if (mounted) setState(() => _error = 'The profile could not be updated.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_profile != null) ...[
                  Text('Contact information', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'First name')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _lastName, decoration: const InputDecoration(labelText: 'Last name')),
                  const SizedBox(height: 12),
                  TextFormField(initialValue: _profile!.phone, readOnly: true, decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 12),
                  TextFormField(initialValue: _profile!.email, readOnly: true, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _occupation, decoration: const InputDecoration(labelText: 'Occupation')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _hometown, decoration: const InputDecoration(labelText: 'Hometown')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _region, decoration: const InputDecoration(labelText: 'Region')),
                  const SizedBox(height: 24),
                  Text('Notification preferences', style: Theme.of(context).textTheme.titleLarge),
                  SwitchListTile(value: _preferredSms, onChanged: (value) => setState(() => _preferredSms = value), title: const Text('SMS notifications'), subtitle: const Text('Allow the school to use SMS for supported notifications.')),
                  SwitchListTile(value: _preferredPush, onChanged: (value) => setState(() => _preferredPush = value), title: const Text('Push notifications'), subtitle: const Text('Allow push notifications when the mobile provider is enabled.')),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save changes')),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
    );
  }
}
