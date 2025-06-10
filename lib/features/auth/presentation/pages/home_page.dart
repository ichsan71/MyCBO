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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _HomeContent(user: state);
          }
          return const ShimmerHomeLoading();
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcomeMessage,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.user.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  MenuCard(
                    title: 'Laporan',
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  MenuCard(
                    title: 'Tambah Jadwal',
                    icon: Icons.add_circle,
                    color: Colors.green,
                    onTap: () => _handleAddSchedule(context),
                  ),
                  if (hasApprovalAccess)
                    MenuCard(
                      title: 'Persetujuan',
                      icon: Icons.approval,
                      color: Colors.red,
                      onTap: () => _navigateToApproval(context),
                    ),
                  if (hasRealisasiVisitAccess)
                    MenuCard(
                      title: 'Realisasi Visit',
                      icon: Icons.check_circle,
                      color: Colors.amber,
                      onTap: () => _navigateToRealisasiVisit(context),
                    ),
                  MenuCard(
                    title: 'Pengaturan',
                    icon: Icons.settings,
                    color: Colors.grey,
                    onTap: () =>
                        Navigator.pushNamed(context, '/notification_settings'),
                  ),
                  MenuCard(
                    title: 'Bantuan',
                    icon: Icons.help,
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddSchedule(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSchedulePage(),
      ),
    );

    if (result == true) {
      if (!context.mounted) return;
      context.read<ScheduleBloc>().add(
            RefreshSchedulesEvent(userId: user.user.idUser),
          );
    }
  }

  void _navigateToApproval(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApprovalListPage(),
      ),
    );
  }

  void _navigateToRealisasiVisit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RealisasiVisitListPage(),
      ),
    );
  }
}
