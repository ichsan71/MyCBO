import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:test_cbo/core/di/injection_container.dart' as di;
import 'package:test_cbo/core/presentation/theme/app_theme.dart';
import 'package:test_cbo/core/presentation/theme/theme_provider.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_event.dart';
import 'package:test_cbo/features/auth/presentation/pages/login_page.dart';
import 'package:test_cbo/features/splash/presentation/pages/splash_screen.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/pages/add_schedule_page.dart';
import 'package:test_cbo/features/schedule/presentation/pages/edit_schedule_page.dart';
import 'package:test_cbo/features/auth/presentation/pages/dashboard_page.dart';
import 'package:test_cbo/features/auth/presentation/pages/schedule_page.dart';
import 'package:test_cbo/features/kpi/presentation/pages/kpi_member_page.dart';
import 'package:test_cbo/features/kpi/presentation/bloc/kpi_member_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:test_cbo/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:test_cbo/features/notifications/data/datasources/local_notification_service.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_bloc.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:flutter/foundation.dart';
import 'package:test_cbo/features/kpi/presentation/bloc/kpi_bloc.dart';
import 'package:test_cbo/features/kpi/domain/entities/kpi_member.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:test_cbo/features/kpi/presentation/pages/kpi_member_detail_page.dart';
import 'package:test_cbo/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:test_cbo/core/services/cleanup_scheduler_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical components only
  await _initializeCriticalComponents();

  runApp(const MyApp());
}

/// Initialize only critical components needed for app startup
Future<void> _initializeCriticalComponents() async {
  try {
    // Add small delay to prevent race conditions with splash screen
    await Future.delayed(const Duration(milliseconds: 50));

    // Set preferred orientations first (fast operation)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style with stable configuration
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Initialize timezone once (move from main to here)
    tz.initializeTimeZones();

    // Initialize dependency injection (critical dependencies only)
    await di.init();

    if (kDebugMode) {
      print('Critical components initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing critical components: $e');
    }
    rethrow;
  }
}

/// Initialize non-critical components in background
Future<void> _initializeNonCriticalComponents() async {
  try {
    // Initialize database in background
    await AppDatabase.instance.initialize();

    // Initialize notifications in background
    final notificationService = di.sl<LocalNotificationService>();
    await notificationService.initialize();

    // Request notification permissions in background (non-blocking)
    final permissionsGranted = await notificationService.requestPermission();
    debugPrint('Notification permissions granted: $permissionsGranted');

    // Initialize cleanup scheduler for photo auto-cleanup
    await CleanupSchedulerService.initializeWithBackgroundSupport();

    if (kDebugMode) {
      print('Non-critical components initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing non-critical components: $e');
    }
    // Don't rethrow - these are non-critical components
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _nonCriticalComponentsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize non-critical components after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNonCriticalComponentsAsync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        if (kDebugMode) {
          print('App resumed from background');
        }
        // Re-initialize components if needed
        if (!_nonCriticalComponentsInitialized) {
          _initializeNonCriticalComponentsAsync();
        }
        break;
      case AppLifecycleState.paused:
        // App is in background
        if (kDebugMode) {
          print('App moved to background');
        }
        break;
      case AppLifecycleState.detached:
        // App is being closed
        if (kDebugMode) {
          print('App is being closed');
        }
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  Future<void> _initializeNonCriticalComponentsAsync() async {
    if (_nonCriticalComponentsInitialized) return;

    try {
      await _initializeNonCriticalComponents();
      setState(() {
        _nonCriticalComponentsInitialized = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize non-critical components: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Use lazy loading for BlocProviders
        BlocProvider<AuthBloc>(
          lazy: false, // Keep this eager as it's needed for splash screen
          create: (context) =>
              di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<NotificationBloc>(
          lazy: true, // Lazy load - only create when needed
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<ScheduleBloc>(
          lazy: true, // Lazy load - only create when needed
          create: (context) => di.sl<ScheduleBloc>(),
        ),
        BlocProvider<KpiBloc>(
          lazy: true, // Lazy load - only create when needed
          create: (context) => di.sl<KpiBloc>(),
        ),
        BlocProvider<KpiMemberBloc>(
          lazy: true, // Lazy load - only create when needed
          create: (context) => di.sl<KpiMemberBloc>(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'Test CBO',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeProvider.themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                MonthYearPickerLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('id', ''),
              ],
              home: const SplashScreen(),
              routes: {
                '/login': (context) => const LoginPage(),
                '/dashboard': (context) => const DashboardPage(),
                '/schedule': (context) => const SchedulePage(),
                '/add_schedule': (context) => BlocProvider(
                      create: (context) => di.sl<AddScheduleBloc>(),
                      child: const AddSchedulePage(),
                    ),
                '/edit_schedule': (context) => EditSchedulePage(
                      scheduleId:
                          ModalRoute.of(context)!.settings.arguments as int,
                    ),
                '/notification_settings': (context) =>
                    const NotificationSettingsPage(),
                '/kpi_member': (context) => BlocProvider.value(
                      value: context.read<KpiMemberBloc>(),
                      child: const KpiMemberPage(),
                    ),
                '/kpi_member_detail': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
                  return KpiMemberDetailPage(
                    kpiMember: args['kpiMember'] as KpiMember,
                    year: args['year'] as String,
                    month: args['month'] as String,
                  );
                },
                '/chatbot': (context) => const ChatbotPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
