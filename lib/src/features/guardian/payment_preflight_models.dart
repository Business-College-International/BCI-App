class PaymentPreflightView {
  PaymentPreflightView({
    required this.requestedAmount,
    required this.selectedOutstandingAmount,
    required this.allocations,
    required this.pendingPaymentCount,
    required this.pendingPaymentAmount,
    required this.reservationAvailable,
    required this.reservationReason,
  });

  final String requestedAmount;
  final String selectedOutstandingAmount;
  final List<PaymentAllocationPreview> allocations;
  final int pendingPaymentCount;
  final String pendingPaymentAmount;
  final bool reservationAvailable;
  final String reservationReason;

  factory PaymentPreflightView.fromJson(Map<String, dynamic> json) {
    final pending = json['pendingPayments'] as Map<String, dynamic>;
    final reservation = json['reservation'] as Map<String, dynamic>;
    return PaymentPreflightView(
      requestedAmount: json['requestedAmount'] as String,
      selectedOutstandingAmount: json['selectedOutstandingAmount'] as String,
      allocations: (json['allocations'] as List<dynamic>)
          .map((item) => PaymentAllocationPreview.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      pendingPaymentCount: pending['count'] as int,
      pendingPaymentAmount: pending['amount'] as String,
      reservationAvailable: reservation['available'] as bool,
      reservationReason: reservation['reason'] as String,
    );
  }
}

class PaymentAllocationPreview {
  PaymentAllocationPreview({
    required this.invoiceNumber,
    required this.amount,
  });

  final String invoiceNumber;
  final String amount;

  factory PaymentAllocationPreview.fromJson(Map<String, dynamic> json) {
    return PaymentAllocationPreview(
      invoiceNumber: json['invoiceNumber'] as String,
      amount: json['amount'] as String,
    );
  }
}
