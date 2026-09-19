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
