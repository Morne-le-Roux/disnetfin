import 'package:disnetfin/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

final pocketBaseProvider = Provider<PocketBase>((ref) {
  final box = Hive.box<dynamic>(AppConfig.appSettingsBox);
  final initialAuth = box.get(AppConfig.pocketBaseAuthKey)?.toString();

  final authStore = AsyncAuthStore(
    initial: initialAuth,
    save: (data) async {
      await box.put(AppConfig.pocketBaseAuthKey, data);
    },
    clear: () async {
      await box.delete(AppConfig.pocketBaseAuthKey);
    },
  );

  return PocketBase(AppConfig.pocketBaseUrl, authStore: authStore);
});
