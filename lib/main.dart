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
import 'package:timezone/timezone.dart' as tz;
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  tz.initializeTimeZones();

  if (kDebugMode) {
    print('Initializing database...');
  }
  await AppDatabase.instance.initialize();

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
          return MultiBlocProvider(
            providers: [
              BlocProvider(
          create: (context) => di.sl<AuthBloc>()
            ..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<NotificationBloc>(),
              ),
              BlocProvider(
                create: (context) => di.sl<ScheduleBloc>(),
              ),
              BlocProvider(
          create: (context) => di.sl<KpiBloc>(),
              ),
              BlocProvider(
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
                  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                  return KpiMemberDetailPage(
                    kpiMember: args['kpiMember'] as KpiMember,
                    year: args['year'] as String,
                    month: args['month'] as String,
                  );
                },
              },
          );
        },
        ),
      ),
    );
  }
}
