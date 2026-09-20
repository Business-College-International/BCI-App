class AssessmentRosterStudentView {
  const AssessmentRosterStudentView({
    required this.id,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  final String id;
  final String? admissionNumber;
  final String firstName;
  final String lastName;
  final String status;

  String get displayName => '$firstName $lastName'.trim();

  factory AssessmentRosterStudentView.fromJson(Map<String, dynamic> json) {
    return AssessmentRosterStudentView(
      id: json['id'] as String,
      admissionNumber: json['admissionNumber'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      status: json['status'] as String,
    );
  }
}

class CreatedAssessmentView {
  const CreatedAssessmentView({
    required this.id,
    required this.title,
    required this.type,
    required this.maxScore,
    required this.weight,
    required this.termCode,
    required this.termName,
    required this.subjectCode,
    required this.subjectName,
  });

  final String id;
  final String title;
  final String type;
  final String maxScore;
  final String? weight;
  final String termCode;
  final String termName;
  final String subjectCode;
  final String subjectName;

  factory CreatedAssessmentView.fromJson(Map<String, dynamic> json) {
    final term = json['term'] as Map<String, dynamic>;
    final subject = json['subject'] as Map<String, dynamic>;
    return CreatedAssessmentView(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      maxScore: json['maxScore'].toString(),
      weight: json['weight']?.toString(),
      termCode: term['code'] as String,
      termName: term['name'] as String,
      subjectCode: subject['code'] as String,
      subjectName: subject['name'] as String,
    );
  }
}

class AssignedAssessmentView {
  const AssignedAssessmentView({
    required this.id,
    required this.title,
    required this.type,
    required this.maxScore,
    required this.weight,
    required this.createdAt,
    required this.results,
  });

  final String id;
  final String title;
  final String type;
  final String maxScore;
  final String? weight;
  final DateTime createdAt;
  final List<AssessmentResultView> results;

  factory AssignedAssessmentView.fromJson(Map<String, dynamic> json) {
    return AssignedAssessmentView(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      maxScore: json['maxScore'].toString(),
      weight: json['weight']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      results: (json['results'] as List<dynamic>? ?? const [])
          .map((item) => AssessmentResultView.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ReportCardCorrectionView {
  const ReportCardCorrectionView({
    required this.id,
    required this.studentId,
    required this.termId,
    required this.targetPublicationId,
    required this.decision,
    required this.reason,
    required this.requestedAt,
    this.decidedAt,
    this.decisionNote,
    this.approvedPublicationId,
  });

  final String id;
  final String studentId;
  final String termId;
  final String targetPublicationId;
  final String decision;
  final String reason;
  final DateTime requestedAt;
  final DateTime? decidedAt;
  final String? decisionNote;
  final String? approvedPublicationId;

  factory ReportCardCorrectionView.fromJson(Map<String, dynamic> json) {
    return ReportCardCorrectionView(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      termId: json['termId'] as String,
      targetPublicationId: json['targetPublicationId'] as String,
      decision: json['decision'] as String,
      reason: json['reason'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      decidedAt: json['decidedAt'] == null ? null : DateTime.parse(json['decidedAt'] as String),
      decisionNote: json['decisionNote'] as String?,
      approvedPublicationId: json['approvedPublicationId'] as String?,
    );
  }
}

class AssessmentResultView {
  const AssessmentResultView({
    required this.id,
    required this.studentId,
    required this.score,
    required this.remark,
    required this.enteredAt,
  });

  final String id;
  final String studentId;
  final String score;
  final String? remark;
  final DateTime enteredAt;

  factory AssessmentResultView.fromJson(Map<String, dynamic> json) {
    return AssessmentResultView(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      score: json['score'].toString(),
      remark: json['remark'] as String?,
      enteredAt: DateTime.parse(json['enteredAt'] as String),
    );
  }
}
