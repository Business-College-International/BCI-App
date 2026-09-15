import '../../core/auth/auth_api.dart';
import 'security_models.dart';

class SecurityApi {
  SecurityApi(this._api);
  final AuthApi _api;

  Future<List<SecuritySession>> sessions() async => _api.securitySessions();

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _api.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> revokeSession(String id) async => _api.revokeSession(id);
  Future<int> revokeAllSessions() async => _api.revokeAllSessions();
}
