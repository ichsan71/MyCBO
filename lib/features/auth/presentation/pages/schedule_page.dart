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
import 'package:intl/intl.dart';

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
  DateTimeRange? _selectedDateRange;

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
              (schedule.namaSpesialis?.isNotEmpty == true &&
                  schedule.namaSpesialis
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ==
                      true);

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
            // Pending: approved must be 0 and not rejected
            matchesFilter =
                schedule.approved == 0 && !lowerDraft.contains('rejected');
            Logger.debug(
                'SchedulePage', 'Filter Pending Approval: $matchesFilter');
          } else if (_selectedFilter == l10n.filterApproved) {
            // Disetujui: check if realisasi_approve is null or nama_approver is null
            matchesFilter = schedule.realisasiApprove == null ||
                schedule.namaApprover == null;
            Logger.debug('SchedulePage', 'Filter Approved: $matchesFilter');
          } else if (_selectedFilter == l10n.filterRejected) {
            // Ditolak: draft contains "rejected"
            matchesFilter = lowerDraft.contains('rejected');
            Logger.debug('SchedulePage', 'Filter Rejected: $matchesFilter');
          } else if (_selectedFilter == l10n.filterCompleted) {
            // Selesai: draft must be "submitted"
            matchesFilter = lowerDraft == 'submitted';
            Logger.debug('SchedulePage', 'Filter Completed: $matchesFilter');
          } else {
            // Semua: no additional filter
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

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final rangeDate =
            "${DateFormat('yyyy-MM-dd').format(picked.start)} - ${DateFormat('yyyy-MM-dd').format(picked.end)}";
        context.read<ScheduleBloc>().add(
              GetSchedulesByRangeDateEvent(
                userId: authState.user.idUser,
                rangeDate: rangeDate,
              ),
            );
      }
    }
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
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: const Text('Pilih Rentang Tanggal',
                        style: TextStyle(fontSize: 13)),
                  ),
                  if (_selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() => _selectedDateRange = null);
                              final authState = context.read<AuthBloc>().state;
                              if (authState is AuthAuthenticated) {
                                context.read<ScheduleBloc>().add(
                                      GetSchedulesEvent(
                                          userId: authState.user.idUser),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated) {
                                    if (context.read<ScheduleBloc>().state
                                        is ScheduleLoaded) {
                                      final schedules = (context
                                              .read<ScheduleBloc>()
                                              .state as ScheduleLoaded)
                                          .schedules;
                                      _filterSchedules(schedules, '');
                                    }
                                  }
                                });
                              },
                              color: Colors.grey[600],
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (value) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      if (context.read<ScheduleBloc>().state
                          is ScheduleLoaded) {
                        final schedules = (context.read<ScheduleBloc>().state
                                as ScheduleLoaded)
                            .schedules;
                        _filterSchedules(schedules, value);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Filter Categories
              Container(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(l10n.filterAll),
                      _buildFilterChip(l10n.filterPendingApproval),
                      _buildFilterChip(l10n.filterApproved),
                      _buildFilterChip(l10n.filterRejected),
                      _buildFilterChip(l10n.filterCompleted),
                    ],
                  ),
                ),
              ),

              if (_searchController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Ditemukan ${_filteredSchedules.length} jadwal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Flexible(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      return BlocConsumer<ScheduleBloc, ScheduleState>(
                        listener: (context, state) {
                          if (state is ScheduleLoaded) {
                            Logger.info('SchedulePage',
                                'Schedule loaded in listener, updating filters');
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
                            if (_filteredSchedules.isEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _updateFilteredSchedules(state.schedules);
                                }
                              });
                              return const ShimmerScheduleListLoading();
                            }
                            if (_filteredSchedules.isEmpty) {
                              return _buildEmptyState();
                            }
                            return RefreshIndicator(
                              onRefresh: () async {
                                _searchController.clear();
                                setState(() {
                                  _selectedFilter = l10n.filterAll;
                                });
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
                          } else if (state is RejectedSchedulesLoaded) {
                            final rejectedSchedules = state.schedules;
                            if (rejectedSchedules.isEmpty) {
                              return _buildEmptyState();
                            }
                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<ScheduleBloc>().add(
                                      FetchRejectedSchedulesEvent(
                                          userId: authState.user.idUser),
                                    );
                              },
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: rejectedSchedules.length,
                                itemBuilder: (context, index) {
                                  final r = rejectedSchedules[index];
                                  // Mapping manual ke Schedule agar bisa pakai _buildScheduleCard
                                  final schedule = Schedule(
                                    id: r.id,
                                    namaUser: r.namaUser,
                                    tipeSchedule: r.tipeSchedule,
                                    tujuan: r.tujuan,
                                    idTujuan: 0,
                                    tglVisit: r.tglVisit,
                                    statusCheckin: r.statusCheckin,
                                    shift: r.shift,
                                    note: r.note,
                                    product: '[]',
                                    draft: r.draft,
                                    statusDraft: '',
                                    alasanReject: '',
                                    namaTujuan: r.namaTujuan,
                                    namaSpesialis: r.namaSpesialis,
                                    namaProduct: r.namaProduct,
                                    namaDivisi: r.namaDivisi,
                                    approved: r.approved,
                                    namaApprover: r.namaRejecter,
                                    realisasiApprove: null,
                                    idUser: 0,
                                    productForIdDivisi: const [],
                                    productForIdSpesialis: const [],
                                    jenis: r.jenis,
                                    approvedBy: null,
                                    rejectedBy: null,
                                    realisasiVisitApproved: null,
                                    createdAt: r.createdAt,
                                  );
                                  return _buildScheduleCard(context, schedule);
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: lowerDraft.contains('rejected')
            ? Border.all(color: Colors.red.shade200, width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: lowerDraft.contains('rejected')
                ? Colors.red.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: lowerDraft.contains('rejected')
                                  ? Colors.red.shade50
                                  : Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: lowerDraft.contains('rejected')
                                      ? Colors.red.shade100.withOpacity(0.5)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.15),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: lowerDraft.contains('rejected')
                                  ? Colors.red.shade700
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule.namaTujuan,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: lowerDraft.contains('rejected')
                                        ? Colors.red.shade700
                                        : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (schedule.namaApprover != null &&
                                    schedule.namaApprover!.isNotEmpty)
                                  Text(
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(schedule.statusCheckin,
                                schedule.draft, schedule.approved),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            displayStatus,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Tanggal:',
                        schedule.tglVisit,
                        lowerDraft.contains('rejected')
                            ? Colors.red.shade400
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.access_time,
                        'Shift:',
                        schedule.shift,
                        lowerDraft.contains('rejected')
                            ? Colors.red.shade400
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.medical_services_outlined,
                        'Spesialis:',
                        schedule.namaSpesialis?.isNotEmpty == true
                            ? schedule.namaSpesialis ?? '-'
                            : '-',
                        lowerDraft.contains('rejected')
                            ? Colors.red.shade400
                            : null,
                      ),
                    ],
                  ),
                ),
                if (schedule.namaProduct?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medication,
                              size: 16,
                              color: lowerDraft.contains('rejected')
                                  ? Colors.red.shade500
                                  : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Produk:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: lowerDraft.contains('rejected')
                                    ? Colors.red.shade500
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: schedule.namaProduct
                                  ?.split(', ')
                                  .map((product) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lowerDraft.contains('rejected')
                                        ? Colors.white
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: lowerDraft.contains('rejected')
                                          ? Colors.red.shade300
                                          : Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    product,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: lowerDraft.contains('rejected')
                                          ? Colors.red.shade700
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                );
                              }).toList() ??
                              [],
                        ),
                      ],
                    ),
                  ),
                ],
                if (schedule.note.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          schedule.note,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      [Color? customColor]) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: customColor ?? Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: customColor ?? Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: customColor ?? Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status, String draft, int approved) {
    final lowerDraft = draft.toLowerCase().trim();
    final lowerStatus = status.toLowerCase().trim();

    if (lowerDraft.contains('rejected')) {
      return Icons.cancel;
    } else if (approved == 0) {
      return Icons.hourglass_empty;
    } else if (approved == 1) {
      return Icons.check_circle;
    } else if (lowerStatus == 'selesai') {
      return Icons.task_alt;
    } else if (lowerStatus == 'check-in') {
      return Icons.login;
    } else if (lowerStatus == 'belum checkout') {
      return Icons.logout;
    } else if (lowerStatus == 'batal') {
      return Icons.block;
    }

    return Icons.info;
  }

  Widget _buildFilterChip(String filter) {
    final bool isSelected = _selectedFilter == filter;
    IconData? iconData;

    // Determine appropriate icon for each filter
    if (filter == AppLocalizations.of(context)!.filterAll) {
      iconData = Icons.filter_list;
    } else if (filter == AppLocalizations.of(context)!.filterPendingApproval) {
      iconData = Icons.pending_actions;
    } else if (filter == AppLocalizations.of(context)!.filterApproved) {
      iconData = Icons.check_circle;
    } else if (filter == AppLocalizations.of(context)!.filterRejected) {
      iconData = Icons.cancel;
    } else if (filter == AppLocalizations.of(context)!.filterCompleted) {
      iconData = Icons.task_alt;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  if (filter == AppLocalizations.of(context)!.filterRejected) {
                    context.read<ScheduleBloc>().add(
                          FetchRejectedSchedulesEvent(
                              userId: authState.user.idUser),
                        );
                  } else if (context.read<ScheduleBloc>().state
                      is ScheduleLoaded) {
                    final schedules =
                        (context.read<ScheduleBloc>().state as ScheduleLoaded)
                            .schedules;
                    _filterSchedules(schedules, _searchController.text);
                  } else {
                    context.read<ScheduleBloc>().add(
                          GetSchedulesEvent(userId: authState.user.idUser),
                        );
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconData != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    filter,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[700],
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
}
