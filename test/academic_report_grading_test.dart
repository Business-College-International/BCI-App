import 'package:flutter_test/flutter_test.dart';

import 'package:bci_mobile_app/src/features/guardian/academic_report_models.dart';

void main() {
  test('parses official grade and policy version from report', () {
    final grading = AcademicReportGrading.fromJson({
      'assigned': true,
      'reason': null,
      'policyVersion': 'GRADING-2026-TEST',
      'gradeCode': 'A',
      'descriptor': 'Excellent',
      'pass': true,
      'points': 4,
    });

    expect(grading.assigned, isTrue);
    expect(grading.gradeCode, 'A');
    expect(grading.policyVersion, 'GRADING-2026-TEST');
    expect(grading.descriptor, 'Excellent');
    expect(grading.pass, isTrue);
    expect(grading.points, 4);
  });
}

test('parses an immutable published report snapshot', () {
  final published = PublishedAcademicReportView.fromJson({
    'id': 'publication-1',
    'status': 'PUBLISHED',
    'publicationVersion': 3,
    'snapshotHash': 'abc123',
    'gradingPolicyVersionId': 'policy-1',
    'publishedAt': '2026-01-10T12:00:00.000Z',
    'snapshotJson': {
      'student': {'firstName': 'Ama', 'lastName': 'Mensah', 'admissionNumber': 'BCI-1'},
      'term': {'id': 'term-1', 'code': 'T1', 'name': 'Term 1'},
      'calculation': {'overallPercentage': 82, 'mode': 'WEIGHTED'},
      'subjects': [],
      'assessments': [],
      'grading': {'assigned': true, 'reason': null, 'policyVersion': 'GRADING-2026-TEST', 'gradeCode': 'A', 'descriptor': 'Excellent', 'pass': true, 'points': 4},
    },
  });

  expect(published.status, 'PUBLISHED');
  expect(published.publicationVersion, 3);
  expect(published.snapshotHash, 'abc123');
  expect(published.snapshot.term.id, 'term-1');
  expect(published.snapshot.grading.gradeCode, 'A');
});
