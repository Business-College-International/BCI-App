import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import 'staff_models.dart';

final staffWorkspaceProvider = FutureProvider.autoDispose<StaffWorkspaceView>((ref) => ref.read(authApiProvider).staffWorkspace());
final myPayrollProvider = FutureProvider.autoDispose<MyPayrollView>((ref) => ref.read(authApiProvider).myPayroll());

class StaffHomePage extends ConsumerWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final workspace = ref.watch(staffWorkspaceProvider);
    final payroll = ref.watch(myPayrollProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BCI Staff Portal'),
        actions: [
          IconButton(onPressed: () { ref.invalidate(staffWorkspaceProvider); ref.invalidate(myPayrollProvider); }, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () => ref.read(authControllerProvider.notifier).signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async { ref.invalidate(staffWorkspaceProvider); ref.invalidate(myPayrollProvider); },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Welcome${user == null || user.firstName.isEmpty ? '' : ', ${user.firstName}'}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(user?.staff?.staffIdNo ?? 'Staff account'),
            const SizedBox(height: 20),
            workspace.when(
              loading: () => const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))),
              error: (_, __) => const Card(child: ListTile(title: Text('Could not load staff workspace'), subtitle: Text('Pull down to retry the authoritative school record.'))),
              data: (data) => Column(children: [
                Card(child: ListTile(title: Text('Employment: ${data.employmentStatus}'), subtitle: Text('${data.department ?? 'School staff'} · ${data.staffIdNo}'))),
                if (data.duties.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Duties'), const SizedBox(height: 8), ...data.duties.map((duty) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.assignment_outlined), title: Text(duty.description), subtitle: Text('${duty.startsAt?.toLocal() ?? 'No start'} → ${duty.endsAt?.toLocal() ?? 'Open'}')))]))),
                if (data.teaching.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Teaching assignments'), const SizedBox(height: 8), ...data.teaching.map((assignment) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.school_outlined), title: Text(assignment.className), subtitle: Text('${assignment.subject} · ${assignment.term}')))]))),
              ]),
            ),
            const SizedBox(height: 12),
            payroll.when(
              loading: () => const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))),
              error: (_, __) => const Card(child: ListTile(title: Text('Payroll information unavailable'), subtitle: Text('Your account may not have payroll-read access yet.'))),
              data: (data) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('My payroll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (data.basePay != null) Text('Current base pay: GHS ${data.basePay}'),
                const SizedBox(height: 8),
                ...data.entries.map((entry) => ListTile(contentPadding: EdgeInsets.zero, title: Text(entry.periodCode), subtitle: Text('${entry.periodStatus} · ${entry.status}'), trailing: Text('GHS ${entry.netPay}'))),
                if (data.entries.isEmpty) const Text('No payroll entries have been issued yet.'),
              ]))),
          ],
        ),
      ),
    );
  }
}
