class AttendanceSummaryView {
  const AttendanceSummaryView({
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.total,
    required this.sessions,
  });

  final int present;
  final int absent;
  final int late;
  final int excused;
  final int total;
  final List<AttendanceSessionView> sessions;

  double? get attendanceRate {
    if (total == 0) return null;
    return ((present + late) / total) * 100;
  }

  double get absenceRate => total == 0 ? 0 : (absent / total) * 100;

  factory AttendanceSummaryView.fromJson(Map<String, dynamic> json) {
    final summary = (json['summary'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final sessions = (json['sessions'] as List<dynamic>? ?? const [])
        .map((item) => AttendanceSessionView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return AttendanceSummaryView(
      present: summary['present'] as int? ?? 0,
      absent: summary['absent'] as int? ?? 0,
      late: summary['late'] as int? ?? 0,
      excused: summary['excused'] as int? ?? 0,
      total: summary['total'] as int? ?? 0,
      sessions: sessions,
    );
  }
}

class AttendanceSessionView {
  const AttendanceSessionView({
    required this.sessionDate,
    required this.periodLabel,
    required this.subjectName,
    required this.status,
    required this.note,
  });

  final DateTime sessionDate;
  final String? periodLabel;
  final String? subjectName;
  final String? status;
  final String? note;

  factory AttendanceSessionView.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    return AttendanceSessionView(
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      periodLabel: json['periodLabel'] as String?,
      subjectName: subject?['name'] as String?,
      status: json['status'] as String?,
      note: json['note'] as String?,
    );
  }
}
