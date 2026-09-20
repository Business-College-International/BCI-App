import 'package:flutter_test/flutter_test.dart';
import 'package:bci_mobile_app/src/features/staff/teacher_assessment_models.dart';

void main() {
  test('parses assessment roster students', () {
    final student = AssessmentRosterStudentView.fromJson({
      'id': 'student-1',
      'admissionNumber': 'BCI-001',
      'firstName': 'Ama',
      'lastName': 'Doe',
      'status': 'ACTIVE',
    });

    expect(student.id, 'student-1');
    expect(student.displayName, 'Ama Doe');
    expect(student.admissionNumber, 'BCI-001');
  });

  test('parses created assessment with decimal values returned by Prisma', () {
    final assessment = CreatedAssessmentView.fromJson({
      'id': 'assessment-1',
      'title': 'First class test',
      'type': 'TEST',
      'maxScore': '50.00',
      'weight': '20.00',
      'term': {'code': 'T1', 'name': 'First Term'},
      'subject': {'code': 'ICT', 'name': 'Information Technology'},
    });

    expect(assessment.id, 'assessment-1');
    expect(assessment.maxScore, '50.00');
    expect(assessment.weight, '20.00');
    expect(assessment.subjectCode, 'ICT');
  });

  test('parses assessment results without changing server values locally', () {
    final result = AssessmentResultView.fromJson({
      'id': 'result-1',
      'studentId': 'student-1',
      'score': '42.50',
      'remark': 'Good work',
      'enteredAt': '2026-09-18T06:00:00.000Z',
    });

    expect(result.score, '42.50');
    expect(result.remark, 'Good work');
    expect(result.enteredAt.toUtc(), DateTime.utc(2026, 9, 18, 6));
  });

  test('parses an assigned assessment with existing results', () {
    final assessment = AssignedAssessmentView.fromJson({
      'id': 'assessment-1',
      'title': 'Mid-term test',
      'type': 'TEST',
      'maxScore': '50.00',
      'weight': '100.00',
      'createdAt': '2026-09-20T08:00:00.000Z',
      'results': [
        {
          'id': 'result-1',
          'studentId': 'student-1',
          'score': '44.00',
          'remark': 'Corrected',
          'enteredAt': '2026-09-20T08:30:00.000Z',
          'enteredBy': 'teacher-1',
        },
      ],
    });

    expect(assessment.id, 'assessment-1');
    expect(assessment.maxScore, '50.00');
    expect(assessment.results).hasLength(1);
    expect(assessment.results.first.score, '44.00');
    expect(assessment.results.first.remark, 'Corrected');
  });

  test('parses report-card correction lifecycle state', () {
    final correction = ReportCardCorrectionView.fromJson({
      'id': 'corr-1',
      'studentId': 'student-1',
      'termId': 'term-1',
      'targetPublicationId': 'pub-1',
      'decision': 'PENDING',
      'reason': 'Corrected test result',
      'requestedAt': '2026-09-20T09:00:00.000Z',
      'decidedAt': null,
      'decisionNote': null,
      'approvedPublicationId': null,
    });

    expect(correction.decision, 'PENDING');
    expect(correction.reason, 'Corrected test result');
    expect(correction.decidedAt, isNull);
  });

}
