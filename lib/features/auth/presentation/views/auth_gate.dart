import 'package:disnetfin/features/auth/presentation/providers/auth_providers.dart';
import 'package:disnetfin/features/auth/presentation/views/login_screen.dart';
import 'package:disnetfin/features/home/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSessionIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSessionIfNeeded();
    }
  }

  Future<void> _refreshSessionIfNeeded() async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    await ref.read(authControllerProvider).refreshSessionSilently();
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const Homescreen();
        }
        return const LoginScreen();
      },
      loading: () => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9F5EB), Color(0xFFE0EEE7)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 14),
                Text('Preparing your finance workspace...'),
              ],
            ),
          ),
        ),
      ),
      error: (_, stackTrace) => const LoginScreen(),
    );
  }
}
