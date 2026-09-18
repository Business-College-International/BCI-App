class StaffDutyView {
  const StaffDutyView({required this.id, required this.description, required this.startsAt, required this.endsAt});
  final String id;
  final String description;
  final DateTime? startsAt;
  final DateTime? endsAt;
  factory StaffDutyView.fromJson(Map<String, dynamic> json) => StaffDutyView(
    id: json['id'] as String,
    description: json['description'] as String,
    startsAt: json['startsAt'] == null ? null : DateTime.parse(json['startsAt'] as String),
    endsAt: json['endsAt'] == null ? null : DateTime.parse(json['endsAt'] as String),
  );
}

class TeachingAssignmentView {
  const TeachingAssignmentView({
    required this.id,
    required this.classId,
    required this.className,
    required this.level,
    required this.programme,
    required this.room,
    required this.subjectId,
    required this.subject,
    required this.termId,
    required this.term,
    required this.termStatus,
  });

  final String id;
  final String classId;
  final String className;
  final String level;
  final String programme;
  final String? room;
  final String subjectId;
  final String subject;
  final String termId;
  final String term;
  final String termStatus;

  bool get canMarkAttendance => termStatus == 'OPEN';

  factory TeachingAssignmentView.fromJson(Map<String, dynamic> json) {
    final classJson = json['class'] as Map<String, dynamic>;
    final subjectJson = json['subject'] as Map<String, dynamic>;
    final termJson = json['term'] as Map<String, dynamic>;
    return TeachingAssignmentView(
      id: json['id'] as String,
      classId: classJson['id'] as String,
      className: classJson['name'] as String,
      level: classJson['level'] as String,
      programme: classJson['programme'] as String,
      room: classJson['room'] as String?,
      subjectId: subjectJson['id'] as String,
      subject: (subjectJson['code'] as String) + ' · ' + (subjectJson['name'] as String),
      termId: termJson['id'] as String,
      term: termJson['name'] as String,
      termStatus: termJson['status'] as String,
    );
  }
}

class StaffWorkspaceView {
  const StaffWorkspaceView({
    required this.staffIdNo,
    required this.department,
    required this.employmentStatus,
    required this.duties,
    required this.teaching,
  });

  final String staffIdNo;
  final String? department;
  final String employmentStatus;
  final List<StaffDutyView> duties;
  final List<TeachingAssignmentView> teaching;

  factory StaffWorkspaceView.fromJson(Map<String, dynamic> json) => StaffWorkspaceView(
    staffIdNo: json['staffIdNo'] as String,
    department: json['department'] as String?,
    employmentStatus: json['employmentStatus'] as String,
    duties: (json['duties'] as List<dynamic>? ?? const [])
        .map((item) => StaffDutyView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    teaching: (json['teaching'] as List<dynamic>? ?? const [])
        .map((item) => TeachingAssignmentView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class PayrollEntryView {
  const PayrollEntryView({required this.id, required this.grossPay, required this.totalDeductions, required this.netPay, required this.status, required this.periodCode, required this.periodStatus, required this.paidAt});
  final String id;
  final String grossPay;
  final String totalDeductions;
  final String netPay;
  final String status;
  final String periodCode;
  final String periodStatus;
  final DateTime? paidAt;
  factory PayrollEntryView.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>;
    return PayrollEntryView(id: json['id'] as String, grossPay: json['grossPay'] as String, totalDeductions: json['totalDeductions'] as String, netPay: json['netPay'] as String, status: json['status'] as String, periodCode: period['code'] as String, periodStatus: period['status'] as String, paidAt: period['paidAt'] == null ? null : DateTime.parse(period['paidAt'] as String));
  }
}

class MyPayrollView {
  const MyPayrollView({required this.staffIdNo, required this.basePay, required this.allowances, required this.deductions, required this.entries});
  final String staffIdNo;
  final String? basePay;
  final Object? allowances;
  final Object? deductions;
  final List<PayrollEntryView> entries;
  factory MyPayrollView.fromJson(Map<String, dynamic> json) {
    final salary = json['salary'] as Map<String, dynamic>?;
    return MyPayrollView(
      staffIdNo: json['staffIdNo'] as String,
      basePay: salary?['basePay'] as String?,
      allowances: salary?['allowances'],
      deductions: salary?['deductions'],
      entries: (json['payrollEntries'] as List<dynamic>? ?? const []).map((item) => PayrollEntryView.fromJson(item as Map<String, dynamic>)).toList(growable: false),
    );
  }
}