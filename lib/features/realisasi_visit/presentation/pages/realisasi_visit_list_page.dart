import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/realisasi_visit.dart';
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
      if (authState.user.role.toUpperCase() == 'GM') {
        // Jika role adalah GM, gunakan API khusus GM
        context.read<RealisasiVisitBloc>().add(
              GetRealisasiVisitsGMEvent(idAtasan: authState.user.idUser),
            );
      } else {
        // Jika role bukan GM, gunakan API normal
        context.read<RealisasiVisitBloc>().add(
              GetRealisasiVisitsEvent(idAtasan: authState.user.idUser),
            );
      }
    }
  }

  // Fungsi untuk menghitung jumlah dokter dari detail
  String _countDoctorsFromDetails(List<RealisasiVisitDetail> details) {
    try {
      // Menghitung jumlah dokter unik berdasarkan idTujuan
      final uniqueDoctorIds = <int>{};
      for (var detail in details) {
        if (detail.tujuan.toLowerCase() == 'dokter') {
          uniqueDoctorIds.add(detail.idTujuan);
        }
      }
      return uniqueDoctorIds.length.toString();
    } catch (e) {
      Logger.error('realisasi_visit', 'Error menghitung jumlah dokter: $e');
      return '0';
    }
  }

  // Fungsi untuk memperbaiki nama dokter pada details jika kosong
  List<RealisasiVisitDetail> _enhanceDetailsWithNameIfMissing(
      List<RealisasiVisitDetail> details) {
    try {
      Logger.info(
          'realisasi_visit', 'Memperbaiki nama dokter untuk ${details.length} detail');

      // Dummy data untuk ilustrasi
      final Map<int, String> doctorNameMap = {
        // ID Dokter -> Nama Dokter
        // Dapat diisi dari database lokal jika diperlukan
      };

      return details.map((detail) {
        // Jika namaDokter kosong dan tujuan adalah dokter, coba isi dengan informasi yang ada
        if (detail.tujuanData.namaDokter.isEmpty &&
            detail.tujuan.toLowerCase() == 'dokter') {
          Logger.info(
              'realisasi_visit',
              'Detail dengan id ${detail.id} memiliki namaDokter kosong, mencoba memperbaiki');

          // Jika kita memiliki mapping ID ke nama dokter, gunakan itu
          final String doctorName = doctorNameMap[detail.idTujuan] ??
              'Dokter (ID: ${detail.idTujuan})';

          // Buat objek RealisasiVisitDetail baru dengan tujuanData yang dimodifikasi
          return RealisasiVisitDetail(
            id: detail.id,
            typeSchedule: detail.typeSchedule,
            tujuan: detail.tujuan,
            idTujuan: detail.idTujuan,
            tglVisit: detail.tglVisit,
            product: detail.product,
            note: detail.note,
            shift: detail.shift,
            jenis: detail.jenis,
            checkin: detail.checkin,
            fotoSelfie: detail.fotoSelfie,
            checkout: detail.checkout,
            fotoSelfieDua: detail.fotoSelfieDua,
            statusTerrealisasi: detail.statusTerrealisasi,
            realisasiVisitApproved: detail.realisasiVisitApproved,
            productData: detail.productData,
            tujuanData: TujuanData(
              idDokter: detail.tujuanData.idDokter,
              namaDokter: doctorName,
            ),
          );
        }

        return detail;
      }).toList();
    } catch (e) {
      Logger.error('realisasi_visit', 'Error saat memperbaiki nama dokter: $e');
      return details;
    }
  }

  // Fungsi untuk menghitung jumlah klinik dari detail
  String _countClinicsFromDetails(List<RealisasiVisitDetail> details) {
    try {
      // Menghitung jumlah klinik unik berdasarkan idTujuan
      final uniqueClinicIds = <int>{};
      for (var detail in details) {
        if (detail.tujuan.toLowerCase() == 'klinik' ||
            detail.tujuan.toLowerCase() == 'apotek' ||
            detail.tujuan.toLowerCase() == 'rs') {
          uniqueClinicIds.add(detail.idTujuan);
        }
      }
      return uniqueClinicIds.length.toString();
    } catch (e) {
      print('Error menghitung jumlah klinik: $e');
      return '0';
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
                      } else if (state is RealisasiVisitGMLoaded) {
                        final realisasiVisitsGM =
                            state.realisasiVisitsGM.where((realisasi) {
                          final matchesSearch = realisasi.namaBawahan
                              .toLowerCase()
                              .contains(_searchQuery);
                          return matchesSearch;
                        }).toList();

                        if (realisasiVisitsGM.isEmpty) {
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
                            itemCount: realisasiVisitsGM.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final realisasiVisitGM = realisasiVisitsGM[index];

                              // Konversi model GM ke model standar
                              final convertedRealisasiVisit = RealisasiVisit(
                                idBawahan: realisasiVisitGM.idBawahan,
                                namaBawahan: realisasiVisitGM.namaBawahan,
                                role: realisasiVisitGM.roleUsers,
                                totalSchedule:
                                    realisasiVisitGM.jumlah.isNotEmpty
                                        ? realisasiVisitGM.jumlah.first.total
                                        : 0,
                                // Ekstrak dan hitung jumlah dokter dari details
                                jumlahDokter: _countDoctorsFromDetails(
                                    realisasiVisitGM.details),
                                // Ekstrak dan hitung jumlah klinik dari details
                                jumlahKlinik: _countClinicsFromDetails(
                                    realisasiVisitGM.details),
                                totalTerrealisasi: realisasiVisitGM
                                        .jumlah.isNotEmpty
                                    ? realisasiVisitGM.jumlah.first.realisasi
                                    : '0',
                                approved: 0,
                                details: _enhanceDetailsWithNameIfMissing(
                                    realisasiVisitGM.details),
                              );

                              return RealisasiVisitCard(
                                realisasiVisit: convertedRealisasiVisit,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RealisasiVisitDetailPage(
                                        realisasiVisit: convertedRealisasiVisit,
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
