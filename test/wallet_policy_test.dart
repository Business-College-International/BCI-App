import 'package:flutter_test/flutter_test.dart';

import 'package:bci_mobile_app/src/features/guardian/wallet_models.dart';

void main() {
  test('keeps wallet balance unavailable when ledger policy is unresolved', () {
    final statement = WalletStatementView.fromJson({
      'exists': true,
      'currency': 'GHS',
      'balance': null,
      'balanceStatus': 'LEDGER_POLICY_REQUIRED',
      'transactions': [
        {
          'id': 'reversal-1',
          'type': 'REVERSAL',
          'direction': null,
          'amount': '10.00',
          'createdAt': '2026-09-19T05:00:00.000Z',
          'providerReference': null,
          'note': 'Requires reconciliation',
        },
      ],
    });

    expect(statement.balance, isNull);
    expect(statement.balanceStatus, 'LEDGER_POLICY_REQUIRED');
    expect(statement.transactions.single.direction, isNull);
  });
}
