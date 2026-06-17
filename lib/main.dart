import 'package:disnetfin/features/home/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DisnetFinApp()));
}

class DisnetFinApp extends StatelessWidget {
  const DisnetFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DisnetFin',
      debugShowCheckedModeBanner: false,
      home: const Homescreen(),
    );
  }
}
