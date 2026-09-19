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
    required this.direction,
    required this.amount,
    required this.createdAt,
    required this.providerReference,
    required this.note,
  });

  final String id;
  final String type;
  final String? direction;
  final String amount;
  final DateTime createdAt;
  final String? providerReference;
  final String? note;

  factory WalletTransactionView.fromJson(Map<String, dynamic> json) {
    return WalletTransactionView(
      id: json['id'] as String,
      type: json['type'] as String,
      direction: json['direction'] as String?,
      amount: json['amount'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      providerReference: json['providerReference'] as String?,
      note: json['note'] as String?,
    );
  }
}
class WalletTopUpView {
  const WalletTopUpView({
    required this.paymentId,
    required this.clientReference,
    required this.status,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.providerReference,
    required this.requiresOtp,
    required this.sessionId,
    required this.network,
    required this.mock,
    required this.purpose,
    required this.retryable,
    required this.failureCode,
    required this.failureMessage,
  });

  final String paymentId;
  final String? clientReference;
  final String status;
  final String amount;
  final String currency;
  final String provider;
  final String? providerReference;
  final bool requiresOtp;
  final String? sessionId;
  final String? network;
  final bool mock;
  final String purpose;
  final bool retryable;
  final String? failureCode;
  final String? failureMessage;

  factory WalletTopUpView.fromJson(Map<String, dynamic> json) {
    return WalletTopUpView(
      paymentId: json['paymentId'] as String? ?? '',
      clientReference: json['clientReference'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',
      amount: json['amount'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'GHS',
      provider: json['provider'] as String? ?? '',
      providerReference: json['providerReference'] as String?,
      requiresOtp: json['requiresOtp'] as bool? ?? false,
      sessionId: json['sessionId'] as String?,
      network: json['network'] as String?,
      mock: json['mock'] as bool? ?? false,
      purpose: json['purpose'] as String? ?? 'WALLET_TOP_UP',
      retryable: json['retryable'] as bool? ?? false,
      failureCode: json['failureCode'] as String?,
      failureMessage: json['failureMessage'] as String?,
    );
  }
}
