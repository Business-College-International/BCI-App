import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import '../../core/auth/auth_models.dart';
import 'attendance_models.dart';

class WardAttendancePage extends StatefulWidget {
  const WardAttendancePage({super.key, required this.ward});

  final WardView ward;

  @override
  State<WardAttendancePage> createState() => _WardAttendancePageState();
}

class _WardAttendancePageState extends State<WardAttendancePage> {
  final _api = AuthApi();
  late Future<AttendanceSummaryView> _attendance;

  @override
  void initState() {
    super.initState();
    _attendance = _loadAttendance();
  }

  Future<AttendanceSummaryView> _loadAttendance() async {
    final report = await _api.currentAcademicReport(widget.ward.id);
    return _api.studentAttendance(widget.ward.id, termId: report.term.id);
  }

  void _retry() {
    setState(() => _attendance = _loadAttendance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.ward.firstName} ${widget.ward.lastName} · Attendance')),
      body: FutureBuilder<AttendanceSummaryView>(
        future: _attendance,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Attendance details could not be loaded.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _retry, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final attendance = snapshot.data!;
          final rate = attendance.attendanceRate;
          final sessions = attendance.sessions;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current-term attendance', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        rate == null ? 'No marked sessions yet' : '${rate.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Present: ${attendance.present} · Late: ${attendance.late} · Absent: ${attendance.absent} · Excused: ${attendance.excused}',
                      ),
                      const SizedBox(height: 4),
                      Text('${attendance.total} marked session(s)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Session history', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (sessions.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.event_busy_outlined),
                    title: Text('No attendance sessions recorded'),
                    subtitle: Text('The school has not recorded marked attendance for this term yet.'),
                  ),
                ),
              ...sessions.map(
                (session) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(_statusIcon(session.status))),
                    title: Text(session.subjectName ?? 'General attendance'),
                    subtitle: Text(
                      _formatDate(session.sessionDate)
                      '${session.periodLabel == null || session.periodLabel!.trim().isEmpty ? '' : ' · ${session.periodLabel}'}'
                      '${session.note == null || session.note!.trim().isEmpty ? '' : '\n${session.note}'}',
                    ),
                    isThreeLine: session.note != null && session.note!.trim().isNotEmpty,
                    trailing: Chip(label: Text(_statusLabel(session.status))),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  String _statusLabel(String? status) => switch (status) {
        'PRESENT' => 'Present',
        'ABSENT' => 'Absent',
        'LATE' => 'Late',
        'EXCUSED' => 'Excused',
        _ => status ?? 'Not marked',
      };

  IconData _statusIcon(String? status) => switch (status) {
        'PRESENT' => Icons.check,
        'ABSENT' => Icons.close,
        'LATE' => Icons.schedule,
        'EXCUSED' => Icons.event_available,
        _ => Icons.help_outline,
      };
}