import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_bar_widget.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/realisasi_visit.dart';
import '../../domain/entities/realisasi_visit_gm.dart';
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
  State<RealisasiVisitListView> createState() => _RealisasiVisitListViewState();
}

class _RealisasiVisitListViewState extends State<RealisasiVisitListView> {
  final TextEditingController _searchController = TextEditingController();
  final List<RealisasiVisit> _gmDetailsList = [];
  String _searchQuery = '';
  RealisasiVisitGM? _selectedBCO;
  List<RealisasiVisitGM> _gmList = [];
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final bool isGM = authState is AuthAuthenticated &&
        authState.user.role.toUpperCase() == 'GM';

    if (isGM) {
      _loadRealisasiVisits();
    } else if (authState is AuthAuthenticated) {
      context.read<RealisasiVisitBloc>().add(
            GetRealisasiVisitsEvent(idAtasan: authState.user.idUser),
          );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRealisasiVisits() async {
    setState(() {
      _isLoadingDetails = true;
      _gmDetailsList.clear();
    });
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RealisasiVisitBloc>().add(
            GetRealisasiVisitsGMEvent(idAtasan: authState.user.idUser),
          );
    }
  }

  Future<void> _loadBCODetails(int bcoId) async {
    setState(() {
      _isLoadingDetails = true;
      _gmDetailsList.clear();
    });
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RealisasiVisitBloc>().add(
            GetRealisasiVisitsGMDetailsEvent(
              idBCO: bcoId,
              idAtasan: authState.user.idUser,
            ),
          );
    }
  }

  // Fungsi untuk menghitung jumlah dokter dari detail
  String _countDoctorsFromDetails(List<RealisasiVisitDetail> details) {
    try {
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

  // Fungsi untuk menghitung jumlah klinik dari detail
  String _countClinicsFromDetails(List<RealisasiVisitDetail> details) {
    try {
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
      Logger.error('realisasi_visit', 'Error menghitung jumlah klinik: $e');
      return '0';
    }
  }

  Widget _buildBCODropdown() {
    // Log current state for debugging
    Logger.info('realisasi_visit_page', '=== DROPDOWN STATE ===');
    Logger.info('realisasi_visit_page', 'Selected BCO ID: ${_selectedBCO?.id}');
    Logger.info(
        'realisasi_visit_page', 'Total BCOs in list: ${_gmList.length}');

    // Create a map to track duplicate IDs
    final Map<int, bool> idMap = {};
    final List<RealisasiVisitGM> uniqueBCOs = [];

    for (var bco in _gmList) {
      if (!idMap.containsKey(bco.id)) {
        idMap[bco.id] = true;
        uniqueBCOs.add(bco);
      } else {
        Logger.error(
            'realisasi_visit_page', 'Duplicate BCO ID found: ${bco.id}');
      }
    }

    Logger.info('realisasi_visit_page', 'Unique BCOs: ${uniqueBCOs.length}');

    // If selected BCO is not in the unique list, reset it
    if (_selectedBCO != null &&
        !uniqueBCOs.any((bco) => bco.id == _selectedBCO!.id)) {
      Logger.info('realisasi_visit_page',
          'Selected BCO not found in unique list, resetting selection');
      _selectedBCO = null;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih BCO',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: _selectedBCO?.id,
            isExpanded: true,
            items: uniqueBCOs.map((bco) {
              Logger.info('realisasi_visit_page',
                  'Creating dropdown item for BCO: ${bco.id} - ${bco.name}');
              return DropdownMenuItem<int>(
                value: bco.id,
                child: Text(
                  '${bco.name} - ${bco.kodeRayon}',
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (int? value) {
              Logger.info(
                  'realisasi_visit_page', 'Dropdown value changed to: $value');
              if (value != null) {
                final selectedBCO =
                    uniqueBCOs.firstWhere((bco) => bco.id == value);
                Logger.info('realisasi_visit_page',
                    'Found matching BCO: ${selectedBCO.name}');
                setState(() {
                  _selectedBCO = selectedBCO;
                  _gmDetailsList.clear();
                });
                _loadBCODetails(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nama...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isGM = authState is AuthAuthenticated &&
        authState.user.role.toUpperCase() == 'GM';

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Realisasi Visit',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (isGM) {
                if (_selectedBCO != null) {
                  _loadBCODetails(_selectedBCO!.id);
                } else {
                  _loadRealisasiVisits();
                }
              } else if (authState is AuthAuthenticated) {
                context.read<RealisasiVisitBloc>().add(
                      GetRealisasiVisitsEvent(idAtasan: authState.user.idUser),
                    );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<RealisasiVisitBloc, RealisasiVisitState>(
        listener: (context, state) {
          Logger.info('realisasi_visit_page', '=== STATE CHANGED ===');
          Logger.info(
              'realisasi_visit_page', 'Current state: ${state.runtimeType}');

          if (state is RealisasiVisitGMLoaded) {
            Logger.info('realisasi_visit_page', '=== API PERTAMA RESPONSE ===');
            Logger.info('realisasi_visit_page',
                'Received ${state.realisasiVisitsGM.length} BCOs');
            for (var bco in state.realisasiVisitsGM) {
              Logger.info('realisasi_visit_page',
                  'BCO in list: ${bco.name} (ID: ${bco.id})');
            }

            setState(() {
              _gmList = state.realisasiVisitsGM;
              Logger.info('realisasi_visit_page',
                  'Updated _gmList length: ${_gmList.length}');
            });
          } else if (state is RealisasiVisitGMDetailsLoaded) {
            Logger.info('realisasi_visit_page', '=== API KEDUA RESPONSE ===');
            Logger.info('realisasi_visit_page',
                'Selected BCO: ${_selectedBCO?.name} (ID: ${_selectedBCO?.id})');
            Logger.info('realisasi_visit_page',
                'Received ${state.realisasiVisitsGM.length} items');

            setState(() {
              _isLoadingDetails = false;
              _gmDetailsList.clear();

              for (var item in state.realisasiVisitsGM) {
                Logger.info('realisasi_visit_page', 'Processing item:');
                Logger.info('realisasi_visit_page', '- ID: ${item.id}');
                Logger.info('realisasi_visit_page', '- Name: ${item.name}');
                Logger.info(
                    'realisasi_visit_page', '- Role: ${item.roleUsers}');
                Logger.info('realisasi_visit_page',
                    '- Details count: ${item.details.length}');

                _gmDetailsList.add(RealisasiVisit(
                  idBawahan: item.id,
                  namaBawahan: item.name,
                  role: item.roleUsers,
                  totalSchedule:
                      item.jumlah.isNotEmpty ? item.jumlah.first.total : 0,
                  jumlahDokter: _countDoctorsFromDetails(item.details),
                  jumlahKlinik: _countClinicsFromDetails(item.details),
                  totalTerrealisasi: item.jumlah.isNotEmpty
                      ? item.jumlah.first.realisasi
                      : '0',
                  approved: 0,
                  details: item.details,
                ));
              }

              Logger.info('realisasi_visit_page',
                  'Updated _gmDetailsList length: ${_gmDetailsList.length}');
            });
          } else if (state is RealisasiVisitError) {
            setState(() {
              _isLoadingDetails = false;
            });
          }
        },
        builder: (context, state) {
          Widget contentWidget;

          if (isGM) {
            List<Widget> children = [
              _buildBCODropdown(),
              _buildSearchField(),
              const SizedBox(height: 16),
            ];

            if (state is RealisasiVisitLoading) {
              _logState('Showing loading state');
              children.add(
                const Expanded(
                  child: ShimmerLoading(),
                ),
              );
            } else if (state is RealisasiVisitError) {
              _logState('Showing error state: ${state.message}');
              children.add(
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Coba Lagi',
                        onPressed: () {
                          if (_selectedBCO != null) {
                            _loadBCODetails(_selectedBCO!.id);
                          } else {
                            _loadRealisasiVisits();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (_selectedBCO == null) {
              _logState('Showing empty state (no BCO selected)');
              children.add(
                Expanded(
                  child: Center(
                    child: Text(
                      'Pilih BCO untuk melihat daftar jadwal',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ),
              );
            } else if (_isLoadingDetails) {
              _logState('Showing details loading state');
              children.add(
                const Expanded(
                  child: ShimmerLoading(),
                ),
              );
            } else {
              _logDataState();
              children.add(
                Expanded(
                  child: Column(
                    children: [
                      _buildBCOInfoCard(),
                      Expanded(
                        child: _gmDetailsList.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada data realisasi visit',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: AppTheme.getSecondaryTextColor(context),
                                  ),
                                ),
                              )
                            : _buildRealisasiVisitList(_gmDetailsList),
                      ),
                    ],
                  ),
                ),
              );
            }

            contentWidget = Column(children: children);
          } else {
            // Tampilan untuk role lain
            if (state is RealisasiVisitLoading) {
              contentWidget = const ShimmerLoading();
            } else if (state is RealisasiVisitError) {
              contentWidget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Coba Lagi',
                      onPressed: () {
                        if (authState is AuthAuthenticated) {
                          context.read<RealisasiVisitBloc>().add(
                                GetRealisasiVisitsEvent(
                                    idAtasan: authState.user.idUser),
                              );
                        }
                      },
                    ),
                  ],
                ),
              );
            } else if (state is RealisasiVisitLoaded) {
              final realisasiVisits = state.realisasiVisits
                  .where((realisasiVisit) =>
                      realisasiVisit.namaBawahan
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      realisasiVisit.role
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();

              contentWidget = Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  if (realisasiVisits.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada realisasi visit yang sesuai dengan pencarian'
                              : 'Tidak ada realisasi visit yang perlu disetujui',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          if (authState is AuthAuthenticated) {
                            context.read<RealisasiVisitBloc>().add(
                                  GetRealisasiVisitsEvent(
                                      idAtasan: authState.user.idUser),
                                );
                          }
                          return Future<void>.value();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: realisasiVisits.length,
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
                                      userId: (context.read<AuthBloc>().state
                                              as AuthAuthenticated)
                                          .user
                                          .idUser,
                                    ),
                                  ),
                                ).then((result) {
                                  // Jika ada perubahan (approval/reject berhasil), refresh data
                                  if (result == true) {
                                    final authState =
                                        context.read<AuthBloc>().state;
                                    if (authState is AuthAuthenticated) {
                                      context.read<RealisasiVisitBloc>().add(
                                            GetRealisasiVisitsEvent(
                                              idAtasan: authState.user.idUser,
                                            ),
                                          );
                                    }
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            } else {
              contentWidget = const ShimmerLoading();
            }
          }

          return contentWidget;
        },
      ),
    );
  }

  void _logState(String message) {
    Logger.info('realisasi_visit_page', message);
  }

  void _logDataState() {
    Logger.info('realisasi_visit_page', 'Showing data state');
    Logger.info('realisasi_visit_page',
        'Selected BCO details: ${_selectedBCO?.name} (${_selectedBCO?.id})');
    Logger.info(
        'realisasi_visit_page', 'Details list count: ${_gmDetailsList.length}');
  }

  Widget _buildBCOInfoCard() {
    if (_selectedBCO == null) return const SizedBox.shrink();

    // Cek jika jumlah kosong atau total = 0
    if (_selectedBCO!.jumlah.isEmpty ||
        (_selectedBCO!.jumlah.isNotEmpty &&
            _selectedBCO!.jumlah.first.total == 0)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RealisasiVisitDetailPage(
                realisasiVisit: RealisasiVisit(
                  idBawahan: _selectedBCO!.id,
                  namaBawahan: _selectedBCO!.name,
                  role: _selectedBCO!.roleUsers,
                  totalSchedule: _selectedBCO!.jumlah.isNotEmpty
                      ? _selectedBCO!.jumlah.first.total
                      : 0,
                  jumlahDokter: _countDoctorsFromDetails(_selectedBCO!.details),
                  jumlahKlinik: _countClinicsFromDetails(_selectedBCO!.details),
                  totalTerrealisasi: _selectedBCO!.jumlah.isNotEmpty
                      ? _selectedBCO!.jumlah.first.realisasi
                      : '0',
                  approved: 0,
                  details: _selectedBCO!.details,
                ),
                userId: (context.read<AuthBloc>().state as AuthAuthenticated)
                    .user
                    .idUser,
              ),
            ),
          ).then((result) {
            // Jika ada perubahan (approval/reject berhasil), refresh data
            if (result == true) {
              if (_selectedBCO != null) {
                _loadBCODetails(_selectedBCO!.id);
              }
            }
          });
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor,
                ],
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informasi BCO
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedBCO!.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedBCO!.kodeRayon,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _selectedBCO!.roleUsers,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical Divider
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 1,
                    color: Colors.white24,
                  ),
                  // Statistik
                  if (_selectedBCO!.jumlah.isNotEmpty)
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCompactStatistic(
                            label: 'Total',
                            value: _selectedBCO!.jumlah.first.total.toString(),
                          ),
                          _buildCompactStatistic(
                            label: 'Realisasi',
                            value: _selectedBCO!.jumlah.first.realisasi,
                          ),
                        ],
                      ),
                    ),
                  // Arrow icon
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatistic({
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRealisasiVisitList(List<RealisasiVisit> realisasiVisits) {
    Logger.info('realisasi_visit_page', '=== BUILDING LIST ===');
    Logger.info(
        'realisasi_visit_page', 'Items to display: ${realisasiVisits.length}');

    // Filter out items with total = 0
    final filteredVisits =
        realisasiVisits.where((visit) => visit.totalSchedule > 0).toList();

    if (filteredVisits.isEmpty) {
      Logger.info('realisasi_visit_page', 'No items to display');
      return Center(
        child: Text(
          'Tidak ada data realisasi visit',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
      );
    }

    Logger.info('realisasi_visit_page',
        'Building list with ${filteredVisits.length} items');
    return RefreshIndicator(
      onRefresh: () {
        if (_selectedBCO != null) {
          return _loadBCODetails(_selectedBCO!.id);
        }
        return Future<void>.value();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredVisits.length,
        itemBuilder: (context, index) {
          final realisasiVisit = filteredVisits[index];
          Logger.info('realisasi_visit_page',
              'Building item $index: ${realisasiVisit.namaBawahan}');
          return RealisasiVisitCard(
            realisasiVisit: realisasiVisit,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealisasiVisitDetailPage(
                    realisasiVisit: realisasiVisit,
                    userId:
                        (context.read<AuthBloc>().state as AuthAuthenticated)
                            .user
                            .idUser,
                  ),
                ),
              ).then((result) {
                // Jika ada perubahan (approval/reject berhasil), refresh data
                if (result == true) {
                  if (_selectedBCO != null) {
                    _loadBCODetails(_selectedBCO!.id);
                  }
                }
              });
            },
          );
        },
      ),
    );
  }
}
