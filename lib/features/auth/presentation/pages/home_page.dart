import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../approval/presentation/pages/approval_list_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:test_cbo/features/schedule/presentation/pages/add_schedule_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final l10n = AppLocalizations.of(context)!;
            final role = state.user.role.toUpperCase();
            final hasApprovalAccess = role == 'ADMIN' ||
                role == 'BCO' ||
                role == 'RSM' ||
                role == 'DM';

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
                      state.user.name,
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
                          _buildMenuCard(
                            'Laporan',
                            Icons.bar_chart,
                            Colors.blue,
                            () {},
                          ),
                          _buildMenuCard(
                            'Tambah Jadwal',
                            Icons.add_circle,
                            Colors.green,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddSchedulePage(),
                                ),
                              );
                            },
                          ),
                          if (hasApprovalAccess)
                            _buildMenuCard(
                              'Persetujuan',
                              Icons.approval,
                              Colors.red,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ApprovalListPage(),
                                  ),
                                );
                              },
                            ),
                          _buildMenuCard(
                            'Target',
                            Icons.flag,
                            Colors.orange,
                            () {},
                          ),
                          _buildMenuCard(
                            'Tim',
                            Icons.people,
                            Colors.purple,
                            () {},
                          ),
                          _buildMenuCard(
                            'Pengaturan',
                            Icons.settings,
                            Colors.grey,
                            () {},
                          ),
                          _buildMenuCard(
                            'Bantuan',
                            Icons.help,
                            Colors.teal,
                            () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
