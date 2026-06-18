import 'dart:async';

import 'package:disnetfin/core/network/pocketbase_client.dart';
import 'package:disnetfin/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(pocketBaseProvider));
});

final authStateProvider = StreamProvider<bool>((ref) {
  final client = ref.watch(pocketBaseProvider);
  final controller = StreamController<bool>();

  controller.add(client.authStore.isValid);

  final subscription = client.authStore.onChange.listen((_) {
    controller.add(client.authStore.isValid);
  });

  ref.onDispose(() async {
    await subscription.cancel();
    await controller.close();
  });

  return controller.stream;
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  const AuthController(this._ref);

  final Ref _ref;

  Future<void> login({required String email, required String password}) async {
    await _ref
        .read(authRepositoryProvider)
        .login(email: email.trim(), password: password);
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
  }

  Future<bool> refreshSessionSilently() async {
    return _ref.read(authRepositoryProvider).refreshSessionSilently();
  }
}

String mapAuthError(Object error) {
  if (error is ClientException) {
    return error.response['message']?.toString() ?? 'Authentication failed.';
  }

  return 'Authentication failed. Please try again.';
}
