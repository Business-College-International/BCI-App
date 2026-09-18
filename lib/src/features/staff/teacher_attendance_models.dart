class TeacherAttendanceMark {
  const TeacherAttendanceMark({
    required this.studentId,
    required this.status,
    this.note,
  });

  final String studentId;
  final String status;
  final String? note;

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'status': status,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
  };
}

class TeacherAttendanceRosterView {
  const TeacherAttendanceRosterView({
    required this.sessionId,
    required this.sessionDate,
    required this.periodLabel,
    required this.className,
    required this.students,
  });

  final String sessionId;
  final DateTime sessionDate;
  final String? periodLabel;
  final String className;
  final List<TeacherAttendanceStudentView> students;

  factory TeacherAttendanceRosterView.fromJson(Map<String, dynamic> json) {
    final session = json['session'] as Map<String, dynamic>;
    final classJson = session['class'] as Map<String, dynamic>;
    return TeacherAttendanceRosterView(
      sessionId: session['id'] as String,
      sessionDate: DateTime.parse(session['sessionDate'] as String),
      periodLabel: session['periodLabel'] as String?,
      className: classJson['name'] as String,
      students: (json['roster'] as List<dynamic>? ?? const [])
          .map((item) => TeacherAttendanceStudentView.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class TeacherAttendanceStudentView {
  const TeacherAttendanceStudentView({
    required this.id,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.existingStatus,
    required this.existingNote,
  });

  final String id;
  final String? admissionNumber;
  final String firstName;
  final String lastName;
  final String? existingStatus;
  final String? existingNote;

  String get displayName => '$firstName $lastName'.trim();

  factory TeacherAttendanceStudentView.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>;
    final attendance = json['attendance'] as Map<String, dynamic>?;
    return TeacherAttendanceStudentView(
      id: student['id'] as String,
      admissionNumber: student['admissionNumber'] as String?,
      firstName: student['firstName'] as String,
      lastName: student['lastName'] as String,
      existingStatus: attendance?['status'] as String?,
      existingNote: attendance?['note'] as String?,
    );
  }
}
