class AcademicReportView {
  const AcademicReportView({
    required this.student,
    required this.term,
    required this.calculation,
    required this.subjects,
    required this.assessments,
    required this.grading,
  });

  final AcademicReportStudent student;
  final AcademicReportTerm term;
  final AcademicReportCalculation calculation;
  final List<AcademicReportSubject> subjects;
  final List<AcademicReportAssessment> assessments;
  final AcademicReportGrading grading;

  factory AcademicReportView.fromJson(Map<String, dynamic> json) {
    return AcademicReportView(
      student: AcademicReportStudent.fromJson(json['student'] as Map<String, dynamic>),
      term: AcademicReportTerm.fromJson(json['term'] as Map<String, dynamic>),
      calculation: AcademicReportCalculation.fromJson(json['calculation'] as Map<String, dynamic>),
      subjects: (json['subjects'] as List<dynamic>? ?? const [])
          .map((item) => AcademicReportSubject.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      assessments: (json['assessments'] as List<dynamic>? ?? const [])
          .map((item) => AcademicReportAssessment.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      grading: AcademicReportGrading.fromJson(json['grading'] as Map<String, dynamic>),
    );
  }
}

class AcademicReportStudent {
  const AcademicReportStudent({required this.firstName, required this.lastName, required this.admissionNumber});
  final String firstName;
  final String lastName;
  final String? admissionNumber;

  factory AcademicReportStudent.fromJson(Map<String, dynamic> json) => AcademicReportStudent(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        admissionNumber: json['admissionNumber'] as String?,
      );
}

class AcademicReportTerm {
  const AcademicReportTerm({required this.code, required this.name});
  final String code;
  final String name;

  factory AcademicReportTerm.fromJson(Map<String, dynamic> json) => AcademicReportTerm(
        code: json['code'] as String,
        name: json['name'] as String,
      );
}

class AcademicReportCalculation {
  const AcademicReportCalculation({required this.overallPercentage, required this.mode});
  final double? overallPercentage;
  final String mode;

  factory AcademicReportCalculation.fromJson(Map<String, dynamic> json) => AcademicReportCalculation(
        overallPercentage: (json['overallPercentage'] as num?)?.toDouble(),
        mode: json['mode'] as String,
      );
}

class AcademicReportSubject {
  const AcademicReportSubject({required this.code, required this.name, required this.assessmentCount, required this.averagePercentage});
  final String code;
  final String name;
  final int assessmentCount;
  final double averagePercentage;

  factory AcademicReportSubject.fromJson(Map<String, dynamic> json) => AcademicReportSubject(
        code: json['code'] as String,
        name: json['name'] as String,
        assessmentCount: json['assessmentCount'] as int,
        averagePercentage: (json['averagePercentage'] as num).toDouble(),
      );
}

class AcademicReportAssessment {
  const AcademicReportAssessment({required this.title, required this.type, required this.score, required this.maxScore, required this.percentage, required this.subjectName});
  final String title;
  final String type;
  final String score;
  final String maxScore;
  final double percentage;
  final String subjectName;

  factory AcademicReportAssessment.fromJson(Map<String, dynamic> json) {
    final assessment = json['assessment'] as Map<String, dynamic>;
    final subject = assessment['subject'] as Map<String, dynamic>;
    return AcademicReportAssessment(
      title: assessment['title'] as String,
      type: assessment['type'] as String,
      score: json['score'] as String,
      maxScore: json['maxScore'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      subjectName: subject['name'] as String,
    );
  }
}

class AcademicReportGrading {
  const AcademicReportGrading({required this.assigned, required this.reason, this.policyVersion, this.gradeCode, this.descriptor, this.pass, this.points});
  final bool assigned;
  final String reason;
  final String? policyVersion;
  final String? gradeCode;
  final String? descriptor;
  final bool? pass;
  final double? points;

  factory AcademicReportGrading.fromJson(Map<String, dynamic> json) => AcademicReportGrading(
        assigned: json['assigned'] as bool? ?? false,
        reason: json['reason'] as String? ?? 'No official grade has been assigned.',
        policyVersion: json['policyVersion'] as String?,
        gradeCode: json['gradeCode'] as String?,
        descriptor: json['descriptor'] as String?,
        pass: json['pass'] as bool?,
        points: (json['points'] as num?)?.toDouble(),
      );
}