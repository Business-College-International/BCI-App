import 'package:flutter_test/flutter_test.dart';

import 'package:bci_mobile_app/src/features/guardian/wallet_models.dart';

void main() {
  test('parses signed wallet transaction direction and top-up state', () {
    final statement = WalletStatementView.fromJson({
      'exists': true,
      'currency': 'GHS',
      'balance': '75.00',
      'balanceStatus': 'CALCULATED',
      'transactions': [
        {
          'id': 'tx-1',
          'type': 'WITHDRAWAL',
          'direction': 'DEBIT',
          'amount': '25.00',
          'createdAt': '2026-09-19T05:00:00.000Z',
          'providerReference': null,
          'note': 'Office withdrawal',
        },
      ],
    });
    expect(statement.balance, '75.00');
    expect(statement.transactions.single.direction, 'DEBIT');

    final topUp = WalletTopUpView.fromJson({
      'paymentId': 'payment-1',
      'status': 'PROCESSING',
      'amount': '50.00',
      'currency': 'GHS',
      'provider': 'MOOLRE',
      'requiresOtp': true,
      'sessionId': 'session-1',
      'mock': true,
      'purpose': 'WALLET_TOP_UP',
    });
    expect(topUp.requiresOtp, isTrue);
    expect(topUp.paymentId, 'payment-1');
  });
}
