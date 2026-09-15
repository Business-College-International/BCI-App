class SecuritySession {
  const SecuritySession({required this.id, required this.createdAt, this.lastUsedAt, required this.expiresAt, this.revokedAt});
  final String id;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;

  factory SecuritySession.fromJson(Map<String, dynamic> json) => SecuritySession(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: json['lastUsedAt'] == null ? null : DateTime.parse(json['lastUsedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        revokedAt: json['revokedAt'] == null ? null : DateTime.parse(json['revokedAt'] as String),
      );
}
