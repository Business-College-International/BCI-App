class ReceiptView {
  const ReceiptView({
    required this.paymentId,
    required this.amount,
    required this.originalAmount,
    required this.refundedAmount,
    required this.netAmount,
    required this.currency,
    required this.purpose,
    required this.status,
    required this.completedAt,
    required this.provider,
    required this.providerReference,
    required this.receiptNumber,
    required this.receiptFileUrl,
    required this.allocations,
  });

  final String paymentId;
  final String amount;
  final String originalAmount;
  final String refundedAmount;
  final String netAmount;
  final String currency;
  final String purpose;
  final String status;
  final DateTime? completedAt;
  final String? provider;
  final String? providerReference;
  final String? receiptNumber;
  final String? receiptFileUrl;
  final List<ReceiptAllocationView> allocations;

  bool get hasRefund => refundedAmount != '0.00';
  bool get fullyRefunded => netAmount == '0.00' && hasRefund;

  factory ReceiptView.fromJson(Map<String, dynamic> json) {
    final receipt = json['receipt'] as Map<String, dynamic>?;
    return ReceiptView(
      paymentId: json['paymentId'] as String,
      amount: json['amount'] as String,
      originalAmount: json['originalAmount'] as String? ?? json['amount'] as String,
      refundedAmount: json['refundedAmount'] as String? ?? '0.00',
      netAmount: json['netAmount'] as String? ?? json['amount'] as String,
      currency: json['currency'] as String,
      purpose: json['purpose'] as String,
      status: json['status'] as String? ?? 'SUCCEEDED',
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      provider: json['provider'] as String?,
      providerReference: json['providerReference'] as String?,
      receiptNumber: receipt?['receiptNumber'] as String?,
      receiptFileUrl: receipt?['fileUrl'] as String?,
      allocations: (json['allocations'] as List<dynamic>? ?? const [])
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
