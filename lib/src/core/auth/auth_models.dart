class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(accessToken: json['accessToken'] as String, refreshToken: json['refreshToken'] as String);
}

class CurrentUser {
  const CurrentUser({required this.id, required this.roles, required this.permissions, required this.firstName, required this.lastName, required this.guardian, required this.staff});
  final String id;
  final List<String> roles;
  final List<String> permissions;
  final String firstName;
  final String lastName;
  final GuardianProfile? guardian;
  final StaffProfile? staff;
  bool get isGuardian => guardian != null;
  bool get isStaff => staff != null;
  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>?;
    final guardianJson = json['guardian'] as Map<String, dynamic>?;
    final staffJson = json['staff'] as Map<String, dynamic>?;
    return CurrentUser(
      id: json['id'] as String,
      roles: List<String>.from(json['roles'] as List<dynamic>? ?? const []),
      permissions: List<String>.from(json['permissions'] as List<dynamic>? ?? const []),
      firstName: person?['firstName'] as String? ?? '',
      lastName: person?['lastName'] as String? ?? '',
      guardian: guardianJson == null ? null : GuardianProfile.fromJson(guardianJson),
      staff: staffJson == null ? null : StaffProfile.fromJson(staffJson),
    );
  }
}

class GuardianProfile {
  const GuardianProfile({required this.personId, required this.preferredSms, required this.preferredPush});
  final String personId;
  final bool preferredSms;
  final bool preferredPush;
  factory GuardianProfile.fromJson(Map<String, dynamic> json) => GuardianProfile(personId: json['personId'] as String, preferredSms: json['preferredSms'] as bool? ?? true, preferredPush: json['preferredPush'] as bool? ?? true);
}

class StaffProfile {
  const StaffProfile({required this.personId, required this.staffIdNo, required this.department, required this.employmentStatus});
  final String personId;
  final String staffIdNo;
  final String? department;
  final String employmentStatus;
  factory StaffProfile.fromJson(Map<String, dynamic> json) => StaffProfile(personId: json['personId'] as String, staffIdNo: json['staffIdNo'] as String, department: json['department'] as String?, employmentStatus: json['employmentStatus'] as String);
}

class WardView {
  const WardView({required this.id, required this.admissionNumber, required this.firstName, required this.lastName, required this.status, required this.relationship, required this.isPrimaryContact, required this.canViewAcademic, required this.canPayFees, required this.canManageWallet});
  final String id;
  final String? admissionNumber;
  final String firstName;
  final String lastName;
  final String status;
  final String relationship;
  final bool isPrimaryContact;
  final bool canViewAcademic;
  final bool canPayFees;
  final bool canManageWallet;
  factory WardView.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>;
    final permissions = json['permissions'] as Map<String, dynamic>? ?? const {};
    return WardView(
      id: student['id'] as String,
      admissionNumber: student['admissionNumber'] as String?,
      firstName: student['firstName'] as String,
      lastName: student['lastName'] as String,
      status: student['status'] as String,
      relationship: json['relationship'] as String,
      isPrimaryContact: json['isPrimaryContact'] as bool? ?? false,
      canViewAcademic: permissions['canViewAcademic'] as bool? ?? false,
      canPayFees: permissions['canPayFees'] as bool? ?? false,
      canManageWallet: permissions['canManageWallet'] as bool? ?? false,
    );
  }
}
