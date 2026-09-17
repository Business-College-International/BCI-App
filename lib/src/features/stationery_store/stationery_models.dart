/// Stationery store models shared by guardian features.
///
/// Mirrors the backend `GET /stationery/catalog` payload:
/// { id, sku, name, price, stockQty, isActive } — `price` is a Prisma
/// Decimal serialized as a string, kept as-is to avoid float drift.
class StationeryItemView {
  const StationeryItemView({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.isActive,
  });

  final String id;
  final String sku;
  final String name;
  final String price;
  final int stockQty;
  final bool isActive;

  factory StationeryItemView.fromJson(Map<String, dynamic> json) =>
      StationeryItemView(
        id: json['id'] as String,
        sku: json['sku'] as String,
        name: json['name'] as String,
        price: json['price'].toString(),
        stockQty: json['stockQty'] as int,
        isActive: json['isActive'] as bool,
      );
}
