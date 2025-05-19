import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../bloc/realisasi_visit_bloc.dart';
import '../widgets/realisasi_visit_card.dart';
import '../widgets/shimmer_loading.dart';
import 'realisasi_visit_detail_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class RealisasiVisitListPage extends StatelessWidget {
  const RealisasiVisitListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RealisasiVisitBloc>(),
      child: const RealisasiVisitListView(),
    );
  }
}

class RealisasiVisitListView extends StatefulWidget {
  const RealisasiVisitListView({Key? key}) : super(key: key);

  @override
  _RealisasiVisitListViewState createState() => _RealisasiVisitListViewState();
}

class _RealisasiVisitListViewState extends State<RealisasiVisitListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRealisasiVisits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRealisasiVisits() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RealisasiVisitBloc>().add(
            GetRealisasiVisitsEvent(idAtasan: authState.user.idUser),
          );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Daftar Realisasi Visit',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama bawahan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  // Cek apakah user memiliki role yang diizinkan
                  final allowedRoles = [
                    'ADMIN',
                    'GM',
                    'BCO',
                    'RSM',
                    'DM',
                    'AM'
                  ];
                  if (!allowedRoles.contains(authState.user.role)) {
                    return Center(
                      child: Text(
                        'Anda tidak memiliki akses ke fitur ini',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return BlocBuilder<RealisasiVisitBloc, RealisasiVisitState>(
                    builder: (context, state) {
                      if (state is RealisasiVisitLoading) {
                        return ListView.builder(
                          itemCount: 5,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            return const ShimmerRealisasiVisitCard();
                          },
                        );
                      } else if (state is RealisasiVisitError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                text: 'Coba Lagi',
                                onPressed: _loadRealisasiVisits,
                                type: AppButtonType.primary,
                              ),
                            ],
                          ),
                        );
                      } else if (state is RealisasiVisitLoaded) {
                        final realisasiVisits =
                            state.realisasiVisits.where((realisasi) {
                          final matchesSearch = realisasi.namaBawahan
                              .toLowerCase()
                              .contains(_searchQuery);
                          return matchesSearch;
                        }).toList();

                        if (realisasiVisits.isEmpty) {
                          return Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada realisasi visit yang sesuai dengan pencarian'
                                  : 'Tidak ada realisasi visit yang perlu disetujui',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => _loadRealisasiVisits(),
                          child: ListView.builder(
                            itemCount: realisasiVisits.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final realisasiVisit = realisasiVisits[index];
                              return RealisasiVisitCard(
                                realisasiVisit: realisasiVisit,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RealisasiVisitDetailPage(
                                        realisasiVisit: realisasiVisit,
                                        userId: authState.user.idUser,
                                      ),
                                    ),
                                  ).then((_) => _loadRealisasiVisits());
                                },
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
