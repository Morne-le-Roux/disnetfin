import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  runApp(const ProviderScope(child: DisnetFinApp()));
}

class DisnetFinApp extends StatelessWidget {
  const DisnetFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DisnetFin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
