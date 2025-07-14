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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Debug info
    if (kDebugMode) {
      print('Screen size: ${screenWidth}x${screenHeight}');
      print('Device pixel ratio: ${MediaQuery.of(context).devicePixelRatio}');
    }

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
        body: Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo dengan ukuran yang sangat terbatas
              ScaleTransition(
                scale: _animation,
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // TEMPORARY: Gunakan icon dulu untuk test
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0277BD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'MAZTA',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // UNCOMMENT INI JIKA INGIN COBA LOGO PNG LAGI
                      // child: Image.asset(
                      //   'assets/images/mazta_logo.png',
                      //   width: 80,
                      //   height: 80,
                      //   fit: BoxFit.contain,
                      //   filterQuality: FilterQuality.medium,
                      //   errorBuilder: (context, error, stackTrace) {
                      //     if (kDebugMode) {
                      //       print('Error loading logo: $error');
                      //     }
                      //     // Fallback dengan icon yang lebih kecil
                      //     return Container(
                      //       width: 80,
                      //       height: 80,
                      //       decoration: BoxDecoration(
                      //         color: const Color(0xFF0277BD),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: const Icon(
                      //         Icons.business,
                      //         size: 30,
                      //         color: Colors.white,
                      //       ),
                      //     );
                      //   },
                      // ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Teks Loading
              FadeTransition(
                opacity: _animation,
                child: Text(
                  l10n.loading,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Progress Indicator
              FadeTransition(
                opacity: _animation,
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0277BD),
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

  // Simplified helper methods (tidak perlu lagi karena menggunakan fixed size)
  double _calculateLogoSize(double screenWidth, double screenHeight) {
    return 100.0; // Fixed size
  }

  double _calculateFontSize(double screenWidth) {
    return 16.0; // Fixed size
  }

  double _calculateProgressSize(double screenWidth) {
    return 20.0; // Fixed size
  }

  double _calculateStrokeWidth(double screenWidth) {
    return 2.0; // Fixed size
  }

  _Spacing _calculateSpacing(double screenHeight) {
    return _Spacing(
      vertical: 16.0,
      horizontal: 16.0,
      small: 8.0,
    );
  }
}

// Helper class for spacing values
class _Spacing {
  final double vertical;
  final double horizontal;
  final double small;

  _Spacing({
    required this.vertical,
    required this.horizontal,
    required this.small,
  });
}
