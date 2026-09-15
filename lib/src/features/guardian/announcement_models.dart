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

class StationeryItemView {
  StationeryItemView({required this.id, required this.name, required this.sku, required this.price, required this.stockQty});

  final String id;
  final String name;
  final String sku;
  final String price;
  final int stockQty;

  factory StationeryItemView.fromJson(Map<String, dynamic> json) => StationeryItemView(
    id: json['id'] as String,
    name: json['name'] as String,
    sku: json['sku'] as String,
    price: json['price'].toString(),
    stockQty: (json['stockQty'] as num).toInt(),
  );
}
