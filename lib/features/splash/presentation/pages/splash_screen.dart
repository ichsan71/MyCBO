import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_event.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_state.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    _checkFirstTime();
    _initialize();
  }

  Future<void> _checkFirstTime() async {
    try {
      if (kDebugMode) {
        print('Memulai pengecekan status first time...');
      }

      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (kDebugMode) {
        print('Status first time: $isFirstTime');
      }

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) {
        if (kDebugMode) {
          print('Widget tidak lagi mounted, navigasi dibatalkan');
        }
        return;
      }

      if (kDebugMode) {
        print('Navigasi ke ${isFirstTime ? 'OnboardingScreen' : 'LoginPage'}');
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              isFirstTime ? const OnboardingScreen() : const LoginPage(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error di splash screen: $e');
      }

      // Fallback ke LoginPage jika terjadi error
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  Future<void> _initialize() async {
    // Initialize notifications
    context.read<NotificationBloc>().add(const InitializeNotifications());

    // Check auth status
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'assets/images/mazta_logo.png',
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    if (kDebugMode) {
                      print('Error memuat gambar: $error');
                    }
                    return const Icon(
                      Icons.image_not_supported,
                      size: 200,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
