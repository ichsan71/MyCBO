import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_cbo/features/auth/presentation/bloc/auth_state.dart';
import 'package:test_cbo/features/auth/presentation/pages/home_page.dart';
import 'package:test_cbo/features/auth/presentation/pages/profile_page.dart';
import 'package:test_cbo/features/auth/presentation/pages/schedule_page.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:test_cbo/features/kpi/presentation/bloc/kpi_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  DateTime? _lastBackPressTime;
  bool _isExiting = false;
  late String _currentYear;
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
    
    // Set default year and month to current date
    final now = DateTime.now();
    _currentYear = now.year.toString();
    _currentMonth = now.month.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Reset exit flag when app is resumed
      _isExiting = false;
      
      // Refresh KPI data when app is resumed
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<KpiBloc>().add(GetKpiDataEvent(
          authState.user.idUser.toString(),
          _currentYear,
          _currentMonth,
        ));
      }
    }
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get initial index from route arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is int) {
        setState(() {
          _selectedIndex = args;
        });
      }

      // Initialize data based on authenticated user
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Initialize KPI data with actual user ID
        context.read<KpiBloc>().add(GetKpiDataEvent(
          authState.user.idUser.toString(),
          _currentYear,
          _currentMonth,
        ));
        _refreshScheduleIfNeeded();
      }
    });
  }

  void _refreshScheduleIfNeeded() {
    if (_selectedIndex == 1) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ScheduleBloc>().add(
              RefreshSchedulesEvent(userId: authState.user.idUser),
            );
      }
    }
  }

  void _showExitSnackbar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tekan sekali lagi untuk keluar',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor.withValues(
          alpha: 230.0,
          red: Theme.of(context).primaryColor.red.toDouble(),
          green: Theme.of(context).primaryColor.green.toDouble(),
          blue: Theme.of(context).primaryColor.blue.toDouble(),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
    );
  }

  Future<void> _performExit() async {
    if (!mounted) return;

    setState(() {
      _isExiting = true;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    // Add delay for smooth exit
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    
    // Exit app
    SystemNavigator.pop();
  }

  Future<bool> _onWillPop() async {
    if (_isExiting) {
      return true;
    }

    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      _showExitSnackbar();
      return false;
    }

    await _performExit();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomePage(),
            SchedulePage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar:
            BlocBuilder<ScheduleBloc, ScheduleState>(builder: (context, state) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });

              // Refresh jadwal saat tab jadwal dipilih
              _refreshScheduleIfNeeded();
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                activeIcon: const Icon(Icons.calendar_today),
                label: l10n.schedules,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: l10n.profile,
              ),
            ],
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            type: BottomNavigationBarType.fixed,
          );
        }),
      ),
    );
  }
}
