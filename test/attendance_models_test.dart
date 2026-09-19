import 'package:flutter_test/flutter_test.dart';

import '../lib/src/features/guardian/attendance_models.dart';

void main() {
  test('parses current-term attendance summary and calculates attendance rate', () {
    final view = AttendanceSummaryView.fromJson({
      'summary': {
        'present': 2,
        'absent': 1,
        'late': 1,
        'excused': 0,
        'total': 4,
      },
      'sessions': [
        {
          'sessionDate': '2026-09-18T12:00:00.000Z',
          'periodLabel': 'Period 3',
          'subject': {'name': 'Mathematics'},
          'status': 'PRESENT',
          'note': null,
        },
      ],
    });

    expect(view.total, 4);
    expect(view.attendanceRate, 75);
    expect(view.absenceRate, 25);
    expect(view.sessions.single.subjectName, 'Mathematics');
    expect(view.sessions.single.status, 'PRESENT');
  });

  test('does not claim an attendance rate when no sessions are marked', () {
    final view = AttendanceSummaryView.fromJson({
      'summary': {'present': 0, 'absent': 0, 'late': 0, 'excused': 0, 'total': 0},
      'sessions': [],
    });

    expect(view.total, 0);
    expect(view.attendanceRate, isNull);
    expect(view.absenceRate, 0);
  });
}