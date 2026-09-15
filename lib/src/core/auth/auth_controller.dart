import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_api.dart';
import 'auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<CurrentUser?>>(
  (ref) => AuthController(ref.read(authApiProvider))..restoreSession(),
);

class AuthController extends StateNotifier<AsyncValue<CurrentUser?>> {
  AuthController(this._api) : super(const AsyncValue.loading());

  final AuthApi _api;

  Future<void> restoreSession() async {
    try {
      final user = await _api.currentUser();
      state = AsyncValue.data(user);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn({required String identifier, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _api.login(identifier: identifier, password: password);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    await _api.logout();
    state = const AsyncValue.data(null);
  }
}

final wardsProvider = FutureProvider.autoDispose<List<WardView>>((ref) async {
  final auth = ref.watch(authControllerProvider).valueOrNull;
  if (auth == null || !auth.isGuardian) return const [];
  return ref.read(authApiProvider).wards();
});
