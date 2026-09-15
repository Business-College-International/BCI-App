class NotificationView {
  const NotificationView({
    required this.id,
    required this.channel,
    required this.provider,
    required this.status,
    required this.createdAt,
    required this.sentAt,
    required this.deliveredAt,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  final String id;
  final String channel;
  final String? provider;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final String title;
  final String body;
  final DateTime? publishedAt;

  bool get isRead => status == 'read';

  factory NotificationView.fromJson(Map<String, dynamic> json) {
    final announcement = json['announcement'] as Map<String, dynamic>?;
    return NotificationView(
      id: json['id'] as String,
      channel: json['channel'] as String,
      provider: json['provider'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] == null ? null : DateTime.parse(json['sentAt'] as String),
      deliveredAt: json['deliveredAt'] == null ? null : DateTime.parse(json['deliveredAt'] as String),
      title: announcement?['title'] as String? ?? 'BCI notification',
      body: announcement?['body'] as String? ?? '',
      publishedAt: announcement?['publishedAt'] == null ? null : DateTime.parse(announcement!['publishedAt'] as String),
    );
  }
}
