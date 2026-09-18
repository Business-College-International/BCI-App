import 'package:flutter_test/flutter_test.dart';
import 'package:bci_mobile_app/src/features/staff/teacher_attendance_models.dart';
import 'package:bci_mobile_app/src/features/staff/staff_models.dart';

void main() {
  test('parses a teaching assignment with server scope identifiers', () {
    final assignment = TeachingAssignmentView.fromJson({
      'id': 'assignment-1',
      'class': {
        'id': 'class-1',
        'name': 'SHS 1 Business A',
        'level': 'SHS1',
        'programme': 'BUSINESS',
        'room': 'B12',
      },
      'subject': {
        'id': 'subject-1',
        'code': 'ICT',
        'name': 'Information and Communication Technology',
      },
      'term': {
        'id': 'term-1',
        'code': 'T1',
        'name': 'First Term',
        'startsAt': '2026-09-01T00:00:00.000Z',
        'endsAt': '2026-12-18T00:00:00.000Z',
        'status': 'OPEN',
      },
    });

    expect(assignment.classId, 'class-1');
    expect(assignment.subjectId, 'subject-1');
    expect(assignment.termId, 'term-1');
    expect(assignment.termStatus, 'OPEN');
    expect(assignment.canMarkAttendance, isTrue);
    expect(assignment.room, 'B12');
  });

  test('serializes an attendance mark without inventing optional fields', () {
    const mark = TeacherAttendanceMark(studentId: 'student-1', status: 'ABSENT');

    expect(mark.toJson(), {
      'studentId': 'student-1',
      'status': 'ABSENT',
    });
  });

  test('parses roster attendance state from the authoritative server response', () {
    final roster = TeacherAttendanceRosterView.fromJson({
      'session': {
        'id': 'session-1',
        'sessionDate': '2026-09-18T12:00:00.000Z',
        'periodLabel': 'Period 3',
        'class': {'id': 'class-1', 'name': 'SHS 1 Business A'},
      },
      'roster': [
        {
          'student': {
            'id': 'student-1',
            'admissionNumber': 'BCI-001',
            'firstName': 'Ama',
            'lastName': 'Doe',
          },
          'attendance': {
            'status': 'PRESENT',
            'note': null,
          },
        },
      ],
    });

    expect(roster.sessionId, 'session-1');
    expect(roster.className, 'SHS 1 Business A');
    expect(roster.students.single.displayName, 'Ama Doe');
    expect(roster.students.single.existingStatus, 'PRESENT');
  });
}
