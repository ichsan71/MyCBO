import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_event.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_state.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final futures = await Future.wait([
        _checkFirstTime(),
        Future.delayed(const Duration(milliseconds: 1000)),
      ]);

      final isFirstTime = futures[0] as bool;

      if (!mounted) return;

      await _controller.forward();

      if (isFirstTime) {
        _navigateToOnboarding();
      } else {
        _initializeAuthAndNotifications();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during app initialization: $e');
      }
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<bool> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isFirstTime') ?? true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking first time: $e');
      }
      return true;
    }
  }

  void _initializeAuthAndNotifications() {
    try {
      if (kDebugMode) {
        print('SplashScreen: Starting auth check...');
      }

      context.read<AuthBloc>().add(const CheckAuthStatusEvent());

      // Add timeout for auth check to prevent infinite loading
      Timer(const Duration(seconds: 10), () {
        if (mounted && !_isInitialized) {
          if (kDebugMode) {
            print('SplashScreen: Auth check timeout, navigating to login');
          }
          _navigateToLogin();
        }
      });

      Future.microtask(() {
        try {
          context.read<NotificationBloc>().add(const InitializeNotifications());
        } catch (e) {
          if (kDebugMode) {
            print('Error initializing notifications: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth and notifications: $e');
      }
      _navigateToLogin();
    }
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (kDebugMode) {
          print(
              'SplashScreen: Received AuthState: ${state.runtimeType}, _isInitialized: $_isInitialized');
        }

        // Only handle final states (not loading) and ensure flag is set after navigation
        if (!_isInitialized && state is! AuthLoading) {
          if (state is AuthAuthenticated) {
            if (kDebugMode) {
              print(
                  'SplashScreen: User authenticated, navigating to dashboard');
            }
            _isInitialized = true;
            _navigateToDashboard();
          } else if (state is AuthUnauthenticated) {
            if (kDebugMode) {
              print(
                  'SplashScreen: User not authenticated, navigating to login');
            }
            _isInitialized = true;
            _navigateToLogin();
          } else if (state is AuthError) {
            if (kDebugMode) {
              print('SplashScreen: Auth error occurred, navigating to login');
            }
            _isInitialized = true;
            _navigateToLogin();
          } else {
            if (kDebugMode) {
              print('SplashScreen: Unknown auth state, navigating to login');
            }
            _isInitialized = true;
            _navigateToLogin();
          }
        } else if (state is AuthLoading) {
          if (kDebugMode) {
            print('SplashScreen: Auth loading...');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                    'assets/images/mazta_logo.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      if (kDebugMode) {
                        print('Error loading image: $error');
                      }
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _animation,
                child: Text(
                  l10n.loading,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _animation,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
