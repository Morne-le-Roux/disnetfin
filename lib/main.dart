import 'package:disnetfin/core/config/app_config.dart';
import 'package:disnetfin/core/theme/app_theme.dart';
import 'package:disnetfin/features/auth/presentation/views/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppConfig.appSettingsBox);
  await Hive.openBox<dynamic>('budget_settings');
  runApp(const ProviderScope(child: DisnetFinApp()));
}

class DisnetFinApp extends StatelessWidget {
  const DisnetFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DisnetFin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
