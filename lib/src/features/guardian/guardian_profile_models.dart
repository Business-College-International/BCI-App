class GuardianProfileView {
  const GuardianProfileView({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.occupation,
    required this.hometown,
    required this.region,
    required this.preferredSms,
    required this.preferredPush,
  });

  final String firstName;
  final String? middleName;
  final String lastName;
  final String? phone;
  final String? email;
  final String? address;
  final String? occupation;
  final String? hometown;
  final String? region;
  final bool preferredSms;
  final bool preferredPush;

  factory GuardianProfileView.fromJson(Map<String, dynamic> json) => GuardianProfileView(
        firstName: (json['firstName'] as String?) ?? '',
        middleName: json['middleName'] as String?,
        lastName: (json['lastName'] as String?) ?? '',
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        occupation: json['occupation'] as String?,
        hometown: json['hometown'] as String?,
        region: json['region'] as String?,
        preferredSms: (json['preferredSms'] as bool?) ?? true,
        preferredPush: (json['preferredPush'] as bool?) ?? true,
      );
}
