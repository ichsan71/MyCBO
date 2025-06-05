import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:test_cbo/features/notification/data/datasources/local_notification_service.dart';
import 'package:test_cbo/features/notification/presentation/bloc/notification_settings_bloc.dart';
import 'package:test_cbo/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:test_cbo/features/notification/presentation/pages/notification_settings_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/presentation/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/dashboard_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/schedule_page.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/schedule/presentation/pages/add_schedule_page.dart';
import 'features/schedule/presentation/pages/edit_schedule_page.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

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

  // Initialize notifications
  final notificationService = di.sl<LocalNotificationService>();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => di.sl<ScheduleBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<NotificationSettingsBloc>()
            ..add(LoadNotificationSettings()),
        ),
        // Tambahkan NotificationBloc
        BlocProvider(
          create: (_) =>
              di.sl<NotificationBloc>()..add(RequestNotificationPermission()),
        ),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationPermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Izin notifikasi diperlukan untuk menerima pemberitahuan',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: MaterialApp(
          title: 'CBO App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id'),
            Locale('en'),
          ],
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/dashboard': (context) => const DashboardPage(),
            '/schedule': (context) => const SchedulePage(),
            '/add_schedule': (context) => const AddSchedulePage(),
            '/edit_schedule': (context) => EditSchedulePage(
                  scheduleId: ModalRoute.of(context)!.settings.arguments as int,
                ),
            '/notification_settings': (context) =>
                const NotificationSettingsPage(),
          },
        ),
      ),
    );
  }
}
