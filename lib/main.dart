import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:test_cbo/core/di/injection_container.dart' as di;
import 'package:test_cbo/core/presentation/theme/app_theme.dart';
import 'package:test_cbo/core/presentation/theme/theme_provider.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/pages/login_page.dart';
import 'package:test_cbo/features/splash/presentation/pages/splash_screen.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/pages/add_schedule_page.dart';
import 'package:test_cbo/features/schedule/presentation/pages/edit_schedule_page.dart';
import 'package:test_cbo/features/auth/presentation/pages/dashboard_page.dart';
import 'package:test_cbo/features/auth/presentation/pages/schedule_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:test_cbo/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:test_cbo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:test_cbo/features/notifications/data/datasources/local_notification_service.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/add_schedule_bloc.dart';
import 'package:test_cbo/core/database/app_database.dart';
import 'package:flutter/foundation.dart';
import 'package:test_cbo/features/kpi/presentation/bloc/kpi_bloc.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Delete database on app start (development only)
  if (kDebugMode) {
    await AppDatabase.instance.deleteDatabase();
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await di.init();

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // Initialize notifications
  final notificationService = di.sl<LocalNotificationService>();
  await notificationService.initialize();

  // Request notification permissions
  final permissionsGranted = await notificationService.requestPermission();
  debugPrint('Notification permissions granted: $permissionsGranted');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => di.sl<AuthBloc>(),
              ),
              BlocProvider(
                create: (context) => di.sl<ScheduleBloc>(),
              ),
              BlocProvider(
                create: (context) => di.sl<NotificationBloc>(),
              ),
              BlocProvider(
                create: (context) => di.sl<KpiBloc>(),
              ),
            ],
            child: MaterialApp(
              title: 'CBO App',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.theme,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                MonthYearPickerLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('id'),
                Locale('en'),
              ],
              locale: const Locale('id'),
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
              },
            ),
          );
        },
      ),
    );
  }
}
