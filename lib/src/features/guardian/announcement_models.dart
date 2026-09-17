class AnnouncementView {
  AnnouncementView({required this.title, required this.body, required this.audienceType, required this.publishedAt});

  final String title;
  final String body;
  final String audienceType;
  final DateTime? publishedAt;

  factory AnnouncementView.fromJson(Map<String, dynamic> json) => AnnouncementView(
    title: json['title'] as String,
    body: json['body'] as String,
    audienceType: json['audienceType'] as String,
    publishedAt: json['publishedAt'] == null ? null : DateTime.parse(json['publishedAt'] as String),
  );
}
