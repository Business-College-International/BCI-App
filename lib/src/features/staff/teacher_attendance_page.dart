import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import 'staff_models.dart';
import 'teacher_attendance_models.dart';

const _attendanceStatuses = <String>[
  'PRESENT',
  'ABSENT',
  'LATE',
  'EXCUSED',
];

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage({super.key, required this.assignment});

  final TeachingAssignmentView assignment;

  @override
  State<TeacherAttendancePage> createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  final _api = AuthApi();
  final _periodController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TeacherAttendanceRosterView? _roster;
  final Map<String, String?> _statuses = <String, String?>{};
  bool _busy = false;

  @override
  void dispose() {
    _periodController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final first = _dateOnly(widget.assignment.termStartsAt);
    final last = _dateOnly(widget.assignment.termEndsAt);
    final initial = _selectedDate.isBefore(first)
        ? first
        : _selectedDate.isAfter(last)
            ? last
            : _dateOnly(_selectedDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Attendance session date',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _roster = null;
        _statuses.clear();
      });
    }
  }

  Future<void> _createSession() async {
    if (!widget.assignment.canMarkAttendance) {
      _showMessage('Attendance cannot be changed for a closed term.');
      return;
    }

    setState(() => _busy = true);
    try {
      final session = await _api.createAttendanceSession(
        termId: widget.assignment.termId,
        classId: widget.assignment.classId,
        subjectId: widget.assignment.subjectId,
        sessionDate: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          12,
        ),
        periodLabel: _periodController.text,
      );

      final sessionId = session['id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw StateError('The school server did not return an attendance session ID.');
      }

      final roster = await _api.attendanceRoster(sessionId);
      if (!mounted) return;

      setState(() {
        _roster = roster;
        _statuses
          ..clear()
          ..addEntries(
            roster.students.map(
              (student) => MapEntry(student.id, student.existingStatus),
            ),
          );
      });
    } catch (error) {
      if (mounted) _showMessage('Could not open attendance: ' + _friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveAttendance() async {
    final roster = _roster;
    if (roster == null) return;

    final unmarked = roster.students
        .where((student) => _statuses[student.id] == null)
        .length;

    if (unmarked > 0) {
      _showMessage('Mark every student before saving. ' + unmarked.toString() + ' student(s) are still unmarked.');
      return;
    }

    setState(() => _busy = true);
    try {
      await _api.markAttendance(
        roster.sessionId,
        roster.students.map((student) {
          return TeacherAttendanceMark(
            studentId: student.id,
            status: _statuses[student.id]!,
          );
        }).toList(growable: false),
      );

      final refreshed = await _api.attendanceRoster(roster.sessionId);
      if (!mounted) return;

      setState(() {
        _roster = refreshed;
        _statuses
          ..clear()
          ..addEntries(
            refreshed.students.map(
              (student) => MapEntry(student.id, student.existingStatus),
            ),
          );
      });

      _showMessage('Attendance saved successfully.');
    } catch (error) {
      if (mounted) _showMessage('Could not save attendance: ' + _friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final roster = _roster;
    final unmarked = roster?.students.where((student) => _statuses[student.id] == null).length ?? 0;
    final assignmentDetails = assignment.term + ' · ' + assignment.level +
        (assignment.programme == 'NONE' ? '' : ' · ' + assignment.programme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark attendance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment.className, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(assignment.subject),
                  const SizedBox(height: 4),
                  Text(assignmentDetails, style: Theme.of(context).textTheme.bodySmall),
                  if (assignment.room != null && assignment.room!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Room ' + assignment.room!),
                  ],
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      assignment.canMarkAttendance ? Icons.lock_open_outlined : Icons.lock_outline,
                      size: 16,
                    ),
                    label: Text(assignment.canMarkAttendance ? 'Term open' : 'Term closed'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Session date'),
                    subtitle: Text(_formatDate(_selectedDate)),
                    trailing: OutlinedButton(
                      onPressed: _busy || !assignment.canMarkAttendance ? null : _pickDate,
                      child: const Text('Change'),
                    ),
                  ),
                  TextField(
                    controller: _periodController,
                    enabled: !_busy && assignment.canMarkAttendance,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Period label (optional)',
                      hintText: 'e.g. Period 3',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy || !assignment.canMarkAttendance ? null : _createSession,
                      icon: const Icon(Icons.playlist_add_check_outlined),
                      label: Text(roster == null ? 'Open attendance roster' : 'Start another session'),
                    ),
                  ),
                  if (roster != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      roster.students.length.toString() + ' students · ' +
                          (unmarked == 0 ? 'Ready to save' : unmarked.toString() + ' unmarked'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (roster == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Open an attendance session to load the authoritative class roster.'),
              ),
            )
          else ...[
            Text('Class roster', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...roster.students.map(
              (student) => Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          student.firstName.isEmpty ? '?' : student.firstName.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.displayName),
                            if (student.admissionNumber != null)
                              Text(
                                student.admissionNumber!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _statuses[student.id],
                        hint: const Text('Mark'),
                        underline: const SizedBox.shrink(),
                        items: _attendanceStatuses
                            .map(
                              (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(_statusLabel(status)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _statuses[student.id] = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy || unmarked > 0 ? null : _saveAttendance,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_busy ? 'Saving…' : 'Save attendance'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return day + '/' + month + '/' + value.year.toString();
  }

  String _statusLabel(String status) => switch (status) {
        'PRESENT' => 'Present',
        'ABSENT' => 'Absent',
        'LATE' => 'Late',
        'EXCUSED' => 'Excused',
        _ => status,
      };

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('capacity') || text.contains('assigned')) {
      return 'The school server rejected this session for its current class/term assignment.';
    }
    if (text.contains('closed')) return 'This term is closed.';
    return text.replaceFirst('Exception: ', '');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
