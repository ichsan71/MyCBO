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
import 'package:test_cbo/core/presentation/widgets/kpi_chart.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

class _HomeContent extends StatelessWidget {
  final AuthAuthenticated user;

  const _HomeContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final role = user.user.role.toUpperCase();
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
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.user.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Performance Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: KPIChart(
                        achievement: 70,
                        weight: 80,
                        result: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Quick Actions',
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
                      _buildMenuCard(
                        context: context,
                        title: 'Laporan',
                        icon: Icons.bar_chart,
                        color: Colors.blue[600]!,
                        onTap: () {},
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Tambah Jadwal',
                        icon: Icons.add_circle,
                        color: Colors.green[600]!,
                        onTap: () =>
                            Navigator.pushNamed(context, '/add_schedule'),
                      ),
                      if (hasApprovalAccess)
                        _buildMenuCard(
                          context: context,
                          title: 'Persetujuan',
                          icon: Icons.approval,
                          color: Colors.red[600]!,
                          onTap: () =>
                              Navigator.pushNamed(context, '/approval'),
                        ),
                      if (hasRealisasiVisitAccess)
                        _buildMenuCard(
                          context: context,
                          title: 'Realisasi Visit',
                          icon: Icons.check_circle,
                          color: Colors.amber[700]!,
                          onTap: () =>
                              Navigator.pushNamed(context, '/realisasi_visit'),
                        ),
                      _buildMenuCard(
                        context: context,
                        title: 'Pengaturan',
                        icon: Icons.settings,
                        color: Colors.grey[700]!,
                        onTap: () => Navigator.pushNamed(
                            context, '/notification_settings'),
                      ),
                      _buildMenuCard(
                        context: context,
                        title: 'Bantuan',
                        icon: Icons.help,
                        color: Colors.teal[600]!,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
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
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
