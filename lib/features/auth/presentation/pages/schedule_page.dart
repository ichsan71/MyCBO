import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_cbo/core/utils/logger.dart';
import '../../../schedule/domain/entities/schedule.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../schedule/presentation/bloc/schedule_event.dart';
import '../../../schedule/presentation/bloc/schedule_state.dart';
import '../../../schedule/presentation/pages/schedule_detail_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_schedule_list_loading.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ScheduleView();
  }
}

class _ScheduleView extends StatefulWidget {
  const _ScheduleView();

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  List<Schedule> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    // Setelah widget dibuat, ambil lokalisasi yang tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          setState(() {
            _selectedFilter = l10n.filterAll;
          });
          Logger.info(
              'SchedulePage', 'Initialized filter to: ${l10n.filterAll}');
        }

        // Ambil data jadwal sekali saat halaman pertama kali dimuat
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.read<ScheduleBloc>().add(
                GetSchedulesEvent(userId: authState.user.idUser),
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSchedules(List<Schedule> schedules, String query) {
    Logger.info('SchedulePage', '===== FILTER SCHEDULES =====');
    Logger.info('SchedulePage', 'Filter Selected: $_selectedFilter');
    Logger.info('SchedulePage', 'Search Query: $query');
    Logger.info('SchedulePage', 'Total Schedules: ${schedules.length}');

    setState(() {
      if (query.isEmpty &&
          _selectedFilter == AppLocalizations.of(context)!.filterAll) {
        _filteredSchedules = List.from(schedules);
        Logger.info('SchedulePage', 'Showing all schedules');
      } else {
        _filteredSchedules = schedules.where((schedule) {
          // Pencarian berdasarkan teks
          final matchesSearch = query.isEmpty ||
              schedule.namaTujuan.toLowerCase().contains(query.toLowerCase()) ||
              (schedule.namaSpesialis.isNotEmpty &&
                  schedule.namaSpesialis
                      .toLowerCase()
                      .contains(query.toLowerCase()));

          // Memeriksa status draft dan approved
          final lowerDraft = schedule.draft.toLowerCase().trim();
          final lowerStatus = schedule.statusCheckin.toLowerCase().trim();

          // Log untuk debugging
          Logger.debug(
              'SchedulePage', '=== FILTERING SCHEDULE ID: ${schedule.id} ===');
          Logger.debug('SchedulePage', 'Tujuan: ${schedule.namaTujuan}');
          Logger.debug('SchedulePage', 'Filter Selected: $_selectedFilter');
          Logger.debug('SchedulePage', 'Draft: $lowerDraft');
          Logger.debug('SchedulePage', 'Status: $lowerStatus');
          Logger.debug('SchedulePage', 'Approved: ${schedule.approved}');
          Logger.debug('SchedulePage', 'Matches Search: $matchesSearch');

          final l10n = AppLocalizations.of(context)!;

          // Filter berdasarkan kategori
          bool matchesFilter = false;
          if (_selectedFilter == l10n.filterPendingApproval) {
            // Belum Disetujui: harus approved=0 dan tidak mengandung "rejected"
            matchesFilter =
                schedule.approved == 0 && !lowerDraft.contains('rejected');
            Logger.debug(
                'SchedulePage', 'Filter Pending Approval: $matchesFilter');
          } else if (_selectedFilter == l10n.filterApproved) {
            // Disetujui: harus approved=1
            matchesFilter = schedule.approved == 1;
            Logger.debug('SchedulePage', 'Filter Approved: $matchesFilter');
          } else if (_selectedFilter == l10n.filterRejected) {
            // Ditolak: draft mengandung "rejected"
            matchesFilter = lowerDraft.contains('rejected');
            Logger.debug('SchedulePage', 'Filter Rejected: $matchesFilter');
          } else if (_selectedFilter == l10n.filterCompleted) {
            // Selesai: status "selesai"
            matchesFilter = lowerStatus == 'selesai';
            Logger.debug('SchedulePage', 'Filter Completed: $matchesFilter');
          } else {
            // Semua: tidak ada filter tambahan
            matchesFilter = true;
            Logger.debug('SchedulePage', 'Filter All: $matchesFilter');
          }

          // Hasil akhir: harus match search dan filter
          final result = matchesSearch && matchesFilter;
          Logger.debug('SchedulePage', 'Final Result: $result');

          return result;
        }).toList();
      }

      // Log hasil filter
      Logger.info(
          'SchedulePage', 'Filtered schedules: ${_filteredSchedules.length}');
    });
  }

  // Memastikan untuk memperbarui filter saat data baru dimuat
  void _updateFilteredSchedules(List<Schedule> schedules) {
    Logger.info('SchedulePage', '===== UPDATE FILTERED SCHEDULES =====');
    Logger.info('SchedulePage', 'Current Filter: $_selectedFilter');
    Logger.info('SchedulePage', 'Search Query: ${_searchController.text}');
    Logger.info('SchedulePage', 'Schedules Count: ${schedules.length}');

    // Selalu terapkan filter untuk data konsisten
    _filterSchedules(schedules, _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: null,
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return FloatingActionButton(
              onPressed: () => _navigateToAddSchedule(),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.scheduleTitle,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (query) {
                  if (context.read<ScheduleBloc>().state is ScheduleLoaded) {
                    final schedules =
                        (context.read<ScheduleBloc>().state as ScheduleLoaded)
                            .schedules;
                    // Gunakan post frame callback untuk mencegah setState selama build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _updateFilteredSchedules(schedules);
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in [
                      l10n.filterAll,
                      l10n.filterPendingApproval,
                      l10n.filterApproved,
                      l10n.filterRejected,
                      l10n.filterCompleted
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: _selectedFilter == filter
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });

                            if (context.read<ScheduleBloc>().state
                                is ScheduleLoaded) {
                              final schedules = (context
                                      .read<ScheduleBloc>()
                                      .state as ScheduleLoaded)
                                  .schedules;
                              // Gunakan post frame callback untuk mencegah setState selama build
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _updateFilteredSchedules(schedules);
                                }
                              });
                            }
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      return BlocConsumer<ScheduleBloc, ScheduleState>(
                        listener: (context, state) {
                          // Perbarui filter ketika data dimuat
                          if (state is ScheduleLoaded) {
                            Logger.info('SchedulePage',
                                'Schedule loaded in listener, updating filters');

                            // Selalu update saat jadwal baru dimuat
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _updateFilteredSchedules(state.schedules);
                              }
                            });
                          }
                        },
                        builder: (context, state) {
                          if (state is ScheduleLoading) {
                            return const ShimmerScheduleListLoading();
                          } else if (state is ScheduleLoaded) {
                            // Jika state loaded tapi belum difilter, update sekali
                            if (_filteredSchedules.isEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _updateFilteredSchedules(state.schedules);
                                }
                              });
                              // Tampilkan loading hanya jika belum difilter
                              return const ShimmerScheduleListLoading();
                            }

                            // Setelah difilter, periksa apakah hasilnya kosong
                            if (_filteredSchedules.isEmpty) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  _searchController.clear();
                                  final l10n = AppLocalizations.of(context)!;
                                  setState(() {
                                    _selectedFilter = l10n.filterAll;
                                  });

                                  // Muat ulang data dengan state awal kosong
                                  context.read<ScheduleBloc>().add(
                                        GetSchedulesEvent(
                                          userId: authState.user.idUser,
                                        ),
                                      );
                                },
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height -
                                              300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.search_off,
                                              size: 70,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Tidak Ada Hasil',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Coba ubah filter atau kata kunci pencarian',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Tampilkan hasil filter dalam ListView dengan RefreshIndicator
                            return RefreshIndicator(
                              onRefresh: () async {
                                _searchController.clear();
                                setState(() {
                                  _selectedFilter = l10n.filterAll;
                                });

                                // Muat ulang data dengan GetSchedulesEvent (bukan RefreshSchedulesEvent)
                                context.read<ScheduleBloc>().add(
                                      GetSchedulesEvent(
                                        userId: authState.user.idUser,
                                      ),
                                    );
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _filteredSchedules.length,
                                itemBuilder: (context, index) {
                                  final schedule = _filteredSchedules[index];
                                  return _buildScheduleCard(
                                    context,
                                    schedule,
                                  );
                                },
                              ),
                            );
                          } else if (state is ScheduleEmpty) {
                            return _buildEmptyState();
                          } else if (state is ScheduleError) {
                            return _buildErrorState(
                                context, authState, state.message);
                          }
                          return const SizedBox();
                        },
                      );
                    }
                    return const Center(
                      child: Text('Silakan login terlebih dahulu'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptySchedule,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noScheduleYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddSchedule(),
            icon: const Icon(Icons.add),
            label: Text(l10n.addSchedule),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk navigasi ke halaman tambah jadwal
  Future<void> _navigateToAddSchedule() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Navigasi ke halaman tambah jadwal dan tunggu hasil
      final result = await Navigator.pushNamed(context, '/add_schedule');

      // Jika kembali dengan hasil sukses, refresh jadwal
      if (result == true) {
        if (!mounted) return;

        // Merefresh jadwal secara langsung
        context.read<ScheduleBloc>().add(
              RefreshSchedulesEvent(userId: authState.user.idUser),
            );

        // Reset filter schedules
        setState(() {
          _filteredSchedules = [];
        });
      }
    }
  }

  Widget _buildErrorState(
      BuildContext context, AuthAuthenticated authState, String message) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingError,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ScheduleBloc>().add(
                    GetSchedulesEvent(userId: authState.user.idUser),
                  );
            },
            child: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, String draft) {
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    Logger.info('SchedulePage', 'Getting status color:');
    Logger.info('SchedulePage', '🔄 Status: $lowerStatus');
    Logger.info('SchedulePage', '🔄 Draft: $lowerDraft');
    Logger.info('SchedulePage',
        '🔄 Draft Contains Rejected?: ${lowerDraft.contains("rejected")}');

    // Prioritas 1: Cek Draft Rejected
    if (lowerDraft.contains('rejected')) {
      Logger.info('SchedulePage', 'Using red color for rejected draft');
      return Colors.red;
    }

    // Prioritas 2: Cek Status
    switch (lowerStatus) {
      case 'belum checkin':
        return Colors.blue;
      case 'check-in':
      case 'belum checkout':
        return Colors.green;
      case 'selesai':
        return Colors.purple;
      case 'batal':
        return Colors.grey;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getDisplayStatus(
      String status, String draft, int approved, String? namaApprover) {
    final l10n = AppLocalizations.of(context)!;
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    Logger.info('SchedulePage', 'Getting display status:');
    Logger.info('SchedulePage', '🔄 Status: $lowerStatus');
    Logger.info('SchedulePage', '🔄 Draft: $lowerDraft');
    Logger.info('SchedulePage', '🔄 Approved: $approved');
    Logger.info('SchedulePage', '🔄 Nama Approver: $namaApprover');

    // Prioritas 1: Cek Draft Rejected
    if (lowerDraft.contains('rejected')) {
      return namaApprover != null && namaApprover.isNotEmpty
          ? l10n.rejectedBy(namaApprover)
          : l10n.rejected;
    }

    // Prioritas 2: Cek Status dan Approval
    if (lowerStatus == 'belum checkin') {
      if (approved == 1) {
        return namaApprover != null && namaApprover.isNotEmpty
            ? l10n.approvedBy(namaApprover)
            : l10n.filterApproved;
      } else {
        return l10n.pendingApproval;
      }
    }

    // Prioritas 3: Status lainnya
    switch (lowerStatus) {
      case 'check-in':
        return l10n.checkedIn;
      case 'belum checkout':
        return l10n.notCheckedOut;
      case 'selesai':
        return namaApprover != null && namaApprover.isNotEmpty
            ? '${l10n.completed} (${l10n.approvedBy(namaApprover)})'
            : l10n.completed;
      case 'batal':
        return l10n.cancelled;
      case 'ditolak':
        return namaApprover != null && namaApprover.isNotEmpty
            ? l10n.rejectedBy(namaApprover)
            : l10n.rejected;
      default:
        return status;
    }
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule) {
    final lowerDraft = schedule.draft.toLowerCase().trim();
    final statusColor = _getStatusColor(schedule.statusCheckin, schedule.draft);
    final displayStatus = _getDisplayStatus(
      schedule.statusCheckin,
      schedule.draft,
      schedule.approved,
      schedule.namaApprover,
    );

    Logger.info('SchedulePage', '=== SCHEDULE CARD INFO ===');
    Logger.info('SchedulePage', 'Schedule ID: ${schedule.id}');
    Logger.info('SchedulePage', 'Status Check-in: ${schedule.statusCheckin}');
    Logger.info('SchedulePage', 'Draft: ${schedule.draft}');
    Logger.info('SchedulePage', 'Draft (lowercase & trim): $lowerDraft');
    Logger.info('SchedulePage',
        'Is Draft Rejected?: ${lowerDraft.contains("rejected")}');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color:
          lowerDraft.contains('rejected') ? Colors.red.shade50 : Colors.white,
      child: InkWell(
        onTap: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleDetailPage(
                  schedule: schedule,
                  userId: authState.user.idUser,
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 8,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        schedule.namaTujuan,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lowerDraft.contains('rejected')
                              ? Colors.red.shade700
                              : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displayStatus,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (schedule.namaApprover != null &&
                    schedule.namaApprover!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      schedule.approved == 1
                          ? 'Disetujui oleh ${schedule.namaApprover}'
                          : lowerDraft.contains('rejected')
                              ? 'Ditolak oleh ${schedule.namaApprover}'
                              : '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: lowerDraft.contains('rejected')
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: lowerDraft.contains('rejected')
                          ? Colors.red.shade400
                          : Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.tglVisit,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: lowerDraft.contains('rejected')
                              ? Colors.red.shade400
                              : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: lowerDraft.contains('rejected')
                          ? Colors.red.shade400
                          : Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Shift ${schedule.shift}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: lowerDraft.contains('rejected')
                              ? Colors.red.shade400
                              : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: lowerDraft.contains('rejected')
                          ? Colors.red.shade400
                          : Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.tipeSchedule,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: lowerDraft.contains('rejected')
                              ? Colors.red.shade400
                              : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
