import 'package:flutter/material.dart';

import 'application_api.dart';

class AdmissionsPage extends StatefulWidget {
  const AdmissionsPage({super.key});

  @override
  State<AdmissionsPage> createState() => _AdmissionsPageState();
}

class _AdmissionsPageState extends State<AdmissionsPage> {
  final _controller = TextEditingController();
  final _api = ApplicationApi();
  ApplicationStatusView? _application;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final trackingCode = _controller.text.trim();
    if (trackingCode.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final application = await _api.getStatus(trackingCode);
      if (!mounted) return;
      setState(() => _application = application);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _application = null;
        _error = 'We could not load that application right now.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BCI School Management')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Admissions', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Check an application using the tracking code returned by BCI.'),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Application tracking code',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _checkStatus(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _checkStatus,
            child: Text(_loading ? 'Checking…' : 'Check status'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_application != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application ${_application!.trackingCode}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('${_application!.levelApplied} · ${_application!.programmeApplied}'),
                    const SizedBox(height: 4),
                    Text('Status: ${_application!.status}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
