import 'package:disnetfin/core/config/app_config.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final PocketBase _client;

  bool get isAuthenticated => _client.authStore.isValid;

  Future<void> login({required String email, required String password}) async {
    await _client
        .collection(AppConfig.authCollection)
        .authWithPassword(email, password);
  }

  Future<void> logout() async {
    _client.authStore.clear();
  }

  Future<bool> refreshSessionSilently() async {
    if (!_client.authStore.isValid) {
      return false;
    }

    try {
      await _client.collection(AppConfig.authCollection).authRefresh();
      return true;
    } catch (_) {
      _client.authStore.clear();
      return false;
    }
  }
}
