import 'package:bci_mobile_app/src/core/auth/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps current user and guardian profile from the backend contract', () {
    final user = CurrentUser.fromJson({
      'id': 'user-1',
      'roles': ['GUARDIAN'],
      'permissions': ['students.read'],
      'person': {'firstName': 'Ama', 'lastName': 'Doe'},
      'guardian': {
        'personId': 'person-1',
        'preferredSms': true,
        'preferredPush': false,
      },
    });

    expect(user.isGuardian, isTrue);
    expect(user.firstName, 'Ama');
    expect(user.guardian?.preferredPush, isFalse);
  });

  test('maps ward-level permissions', () {
    final ward = WardView.fromJson({
      'student': {
        'id': 'student-1',
        'admissionNumber': 'BCI-001',
        'firstName': 'Kojo',
        'lastName': 'Doe',
        'status': 'ACTIVE',
      },
      'relationship': 'parent',
      'isPrimaryContact': true,
      'permissions': {
        'canViewAcademic': true,
        'canPayFees': false,
        'canManageWallet': true,
      },
    });

    expect(ward.isPrimaryContact, isTrue);
    expect(ward.canViewAcademic, isTrue);
    expect(ward.canPayFees, isFalse);
    expect(ward.canManageWallet, isTrue);
  });
}
