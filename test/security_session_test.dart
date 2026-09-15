import 'package:flutter_test/flutter_test.dart';

import 'package:bci_mobile_app/src/features/security/security_models.dart';

void main() {
  test('parses a security session without exposing token material', () {
    final session = SecuritySession.fromJson({
      'id': 'session-1',
      'createdAt': '2026-09-15T10:00:00.000Z',
      'lastUsedAt': '2026-09-15T11:00:00.000Z',
      'expiresAt': '2026-10-15T10:00:00.000Z',
      'revokedAt': null,
    });

    expect(session.id, 'session-1');
    expect(session.revokedAt, isNull);
    expect(session.expiresAt.year, 2026);
  });
}
