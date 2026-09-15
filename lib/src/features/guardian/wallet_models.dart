class WalletStatementView {
  const WalletStatementView({
    required this.exists,
    required this.currency,
    required this.balance,
    required this.balanceStatus,
    required this.transactions,
  });

  final bool exists;
  final String currency;
  final String? balance;
  final String balanceStatus;
  final List<WalletTransactionView> transactions;

  factory WalletStatementView.fromJson(Map<String, dynamic> json) {
    return WalletStatementView(
      exists: json['exists'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'GHS',
      balance: json['balance'] as String?,
      balanceStatus: json['balanceStatus'] as String? ?? 'UNKNOWN',
      transactions: (json['transactions'] as List<dynamic>? ?? const [])
          .map((item) => WalletTransactionView.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class WalletTransactionView {
  const WalletTransactionView({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.providerReference,
    required this.note,
  });

  final String id;
  final String type;
  final String amount;
  final DateTime createdAt;
  final String? providerReference;
  final String? note;

  factory WalletTransactionView.fromJson(Map<String, dynamic> json) {
    return WalletTransactionView(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      providerReference: json['providerReference'] as String?,
      note: json['note'] as String?,
    );
  }
}
