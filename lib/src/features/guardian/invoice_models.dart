class InvoiceView {
  const InvoiceView({
    required this.id,
    required this.invoiceNumber,
    required this.termId,
    required this.status,
    required this.issuedAt,
    required this.dueAt,
    required this.totalAmount,
    required this.amountAllocated,
    required this.outstandingAmount,
    required this.lines,
  });

  final String id;
  final String invoiceNumber;
  final String termId;
  final String status;
  final DateTime issuedAt;
  final DateTime? dueAt;
  final String totalAmount;
  final String amountAllocated;
  final String outstandingAmount;
  final List<InvoiceLineView> lines;

  factory InvoiceView.fromJson(Map<String, dynamic> json) {
    return InvoiceView(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      termId: json['termId'] as String,
      status: json['status'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      dueAt: json['dueAt'] == null ? null : DateTime.parse(json['dueAt'] as String),
      totalAmount: json['totalAmount'] as String,
      amountAllocated: json['amountAllocated'] as String,
      outstandingAmount: json['outstandingAmount'] as String,
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .map((item) => InvoiceLineView.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class InvoiceLineView {
  const InvoiceLineView({
    required this.id,
    required this.description,
    required this.amountDue,
  });

  final String id;
  final String description;
  final String amountDue;

  factory InvoiceLineView.fromJson(Map<String, dynamic> json) {
    return InvoiceLineView(
      id: json['id'] as String,
      description: json['description'] as String,
      amountDue: json['amountDue'] as String,
    );
  }
}
