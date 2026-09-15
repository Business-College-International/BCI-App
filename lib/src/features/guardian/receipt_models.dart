class ReceiptView {
  const ReceiptView({
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.purpose,
    required this.completedAt,
    required this.provider,
    required this.providerReference,
    required this.receiptNumber,
    required this.receiptFileUrl,
    required this.allocations,
  });

  final String paymentId;
  final String amount;
  final String currency;
  final String purpose;
  final DateTime? completedAt;
  final String? provider;
  final String? providerReference;
  final String? receiptNumber;
  final String? receiptFileUrl;
  final List<ReceiptAllocationView> allocations;

  factory ReceiptView.fromJson(Map<String, dynamic> json) {
    final receipt = json['receipt'] as Map<String, dynamic>?;
    return ReceiptView(
      paymentId: json['paymentId'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      purpose: json['purpose'] as String,
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      provider: json['provider'] as String?,
      providerReference: json['providerReference'] as String?,
      receiptNumber: receipt?['receiptNumber'] as String?,
      receiptFileUrl: receipt?['fileUrl'] as String?,
      allocations: (json['allocations'] as List<dynamic>)
          .map((item) => ReceiptAllocationView.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ReceiptAllocationView {
  const ReceiptAllocationView({
    required this.invoiceNumber,
    required this.termId,
    required this.amount,
  });

  final String invoiceNumber;
  final String termId;
  final String amount;

  factory ReceiptAllocationView.fromJson(Map<String, dynamic> json) => ReceiptAllocationView(
        invoiceNumber: json['invoiceNumber'] as String,
        termId: json['termId'] as String,
        amount: json['amount'] as String,
      );
}
