import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../approval/presentation/pages/approval_list_page.dart';
import '../../../realisasi_visit/presentation/pages/realisasi_visit_list_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:test_cbo/features/schedule/presentation/pages/add_schedule_page.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_home_loading.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:test_cbo/features/schedule/presentation/bloc/schedule_event.dart';
import '../widgets/menu_card.dart';
import 'package:test_cbo/features/kpi/presentation/widgets/kpi_chart_new.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:test_cbo/core/presentation/theme/theme_provider.dart';
import 'package:test_cbo/features/kpi/presentation/bloc/kpi_bloc.dart';
import 'package:test_cbo/features/kpi/presentation/widgets/kpi_chart_shimmer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _HomeContent(user: state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final AuthAuthenticated user;

  const _HomeContent({required this.user});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> with WidgetsBindingObserver {
  String? _currentUserId;
  bool _isFirstLoad = true;
  bool _mounted = true;
  late String _currentYear;
  late String _currentMonth;
  bool _isManualRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentUserId = widget.user.user.idUser.toString();
    
    // Set default year and month to current date
    final now = DateTime.now();
    _currentYear = now.year.toString();
    _currentMonth = now.month.toString().padLeft(2, '0');
    
    // Delay the first load slightly to ensure proper initialization
    Future.microtask(() {
      if (_mounted) {
        _refreshKpiData(isForceRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _mounted) {
      _refreshKpiData(isForceRefresh: true);
    }
  }

  @override
  void didUpdateWidget(covariant _HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_mounted) return;
    
    final newUserId = widget.user.user.idUser.toString();
    
    // Always refresh on user change
    if (_currentUserId != newUserId) {
      _currentUserId = newUserId;
      _isFirstLoad = true; // Reset first load flag for new user
      
      // Ensure widget is mounted and use force refresh
      if (_mounted) {
        _refreshKpiData(isForceRefresh: true);
      }
    }
  }

  void _refreshKpiData({bool isForceRefresh = false}) {
    if (!_mounted) return;
    
    final bloc = context.read<KpiBloc>();
    
    if (isForceRefresh) {
      // Update to current date only if it's a manual refresh (from refresh button)
      if (_isManualRefresh) {
        final now = DateTime.now();
        debugPrint('Manual refresh - Updating to current date: ${now.year}-${now.month}');
        setState(() {
          _currentYear = now.year.toString();
          _currentMonth = now.month.toString().padLeft(2, '0');
          _isManualRefresh = false;
        });
      } else if (_isFirstLoad) {
        debugPrint('First load - Using current date');
        _isFirstLoad = false;
      } else {
        debugPrint('Force refresh - Using selected date: $_currentYear-$_currentMonth');
      }
      
      bloc.add(ResetAndRefreshKpiDataEvent(_currentUserId ?? '', _currentYear, _currentMonth));
    } else {
      debugPrint('Normal refresh - Using selected date: $_currentYear-$_currentMonth');
      bloc.add(GetKpiDataEvent(_currentUserId ?? '', _currentYear, _currentMonth));
    }
  }

  void _handleFilterChanged(String year, String month) {
    debugPrint('Filter changed to year: $year, month: $month');
    setState(() {
      _currentYear = year;
      _currentMonth = month;
      _isManualRefresh = false;
    });
    
    // Use GetKpiDataEvent for filter changes to preserve selected date
    final bloc = context.read<KpiBloc>();
    bloc.add(GetKpiDataEvent(_currentUserId ?? '', year, month));
  }

  @override
  Widget build(BuildContext context) {
    final newUserId = widget.user.user.idUser.toString();
    if (_currentUserId != newUserId) {
      _currentUserId = newUserId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshKpiData(isForceRefresh: true);
        }
      });
    }
    final l10n = AppLocalizations.of(context)!;
    final role = widget.user.user.role.toUpperCase();
    final hasApprovalAccess = role == 'ADMIN' ||
        role == 'BCO' ||
        role == 'RSM' ||
        role == 'DM' ||
        role == 'GM';
    final hasRealisasiVisitAccess = role == 'ADMIN' ||
        role == 'GM' ||
        role == 'BCO' ||
        role == 'RSM' ||
        role == 'DM' ||
        role == 'AM';
    final hasKpiAccess = role != 'PS';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.performanceOverview,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            BlocBuilder<KpiBloc, KpiState>(
                              builder: (context, state) {
                                if (state is KpiLoaded) {
                                  return IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isManualRefresh = true;
                                      });
                                      _refreshKpiData(isForceRefresh: true);
                                    },
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<KpiBloc, KpiState>(
                        builder: (context, state) {
                          if (state is KpiLoading) {
                            return const KpiChartShimmer();
                          } else if (state is KpiLoaded && state.kpiData.dataKpiAtasan.isNotEmpty) {
                            return KpiChartNew(
                              kpiData: state.kpiData.dataKpiAtasan.first.grafik,
                              onRefresh: () => _refreshKpiData(isForceRefresh: true),
                              onFilterChanged: _handleFilterChanged,
                              currentYear: _currentYear,
                              currentMonth: _currentMonth,
                            );
                          } else if (state is KpiError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.message,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _refreshKpiData(isForceRefresh: true),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(
                                      'Coba Lagi',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quickActions,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            children: [
                              if (hasKpiAccess)
                                _buildMenuCard(
                                  context: context,
                                  title: l10n.report,
                                  icon: Icons.bar_chart,
                                  color: Colors.blue[600]!,
                                  onTap: () => Navigator.pushNamed(context, '/kpi_member'),
                                ),
                              _buildMenuCard(
                                context: context,
                                title: l10n.addSchedule,
                                icon: Icons.add_circle,
                                color: Colors.green[600]!,
                                onTap: () =>
                                    Navigator.pushNamed(context, '/add_schedule'),
                              ),
                              if (hasApprovalAccess)
                                _buildMenuCard(
                                  context: context,
                                  title: l10n.approval,
                                  icon: Icons.approval,
                                  color: Colors.orange[600]!,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ApprovalListPage(),
                                      settings: const RouteSettings(name: ApprovalListPage.routeName),
                                    ),
                                  ),
                                ),
                              if (hasRealisasiVisitAccess)
                                _buildMenuCard(
                                  context: context,
                                  title: l10n.realisasiVisit,
                                  icon: Icons.assignment_turned_in,
                                  color: Colors.purple[600]!,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RealisasiVisitListPage(),
                                    ),
                                  ),
                                ),
                              _buildMenuCard(
                                context: context,
                                title: l10n.settings,
                                icon: Icons.settings,
                                color: Colors.grey[700]!,
                                onTap: () => Navigator.pushNamed(
                                    context, '/notification_settings'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
