import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/presentation/widgets/shimmer_schedule_list_loading.dart';
import '../../../schedule/presentation/utils/schedule_status_helper.dart';
import '../../../schedule/domain/entities/schedule.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../schedule/presentation/bloc/schedule_bloc.dart';
import '../../../schedule/presentation/bloc/schedule_event.dart';
import '../../../schedule/presentation/bloc/schedule_state.dart';
import '../../../schedule/presentation/pages/schedule_detail_page.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '';
  List<Schedule> _filteredSchedules = [];
  DateTimeRange? _selectedDateRange;
  bool _isInitialized = false;
  List<Schedule> _allSchedules = [];
  bool _isLoadingMore = false;
  int _currentPage = 1;
  ScheduleState? _currentState;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedFilter = '';
    _scrollController.addListener(_onScroll);

    // Schedule the initial load after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    if (!_isInitialized) {
      _selectedFilter = AppLocalizations.of(context)!.filterAll;
      _isInitialized = true;

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Hanya panggil GetSchedulesEvent untuk load awal
        context.read<ScheduleBloc>().add(
              GetSchedulesEvent(userId: authState.user.idUser),
            );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (!_isLoadingMore &&
        _currentState is ScheduleLoaded &&
        (_currentState as ScheduleLoaded).hasMoreData) {
      setState(() {
        _isLoadingMore = true;
      });

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Untuk sementara, kita tidak menggunakan pagination
        // dan hanya merefresh data normal
        context.read<ScheduleBloc>().add(
              GetSchedulesEvent(userId: authState.user.idUser),
            );
      }
    }
  }

  List<Schedule> _getFilteredSchedules(List<Schedule> schedules, String query) {
    final l10n = AppLocalizations.of(context)!;
    final searchQuery = query.toLowerCase();

    Logger.info('SchedulePage', '===== START FILTERING SCHEDULES =====');
    Logger.info(
        'SchedulePage', 'Total schedules to filter: ${schedules.length}');
    Logger.info('SchedulePage', 'Search query: "$searchQuery"');
    Logger.info('SchedulePage', 'Selected filter: "$_selectedFilter"');
    Logger.info(
        'SchedulePage', 'Has date range: ${_selectedDateRange != null}');

    if (_selectedDateRange != null) {
      Logger.info('SchedulePage', 'Date range:');
      Logger.info('SchedulePage', '  Start: ${_selectedDateRange!.start}');
      Logger.info('SchedulePage', '  End: ${_selectedDateRange!.end}');
    }

    if (schedules.isEmpty) {
      Logger.info('SchedulePage', 'No schedules to filter');
      return [];
    }

    // Log sample data
    Logger.info('SchedulePage', 'Sample schedule before filtering:');
    final sampleSchedule = schedules[0];
    Logger.info('SchedulePage', '  ID: ${sampleSchedule.id}');
    Logger.info('SchedulePage', '  Created At: ${sampleSchedule.createdAt}');
    Logger.info('SchedulePage', '  Visit date: ${sampleSchedule.tglVisit}');
    Logger.info('SchedulePage', '  Status: ${sampleSchedule.statusCheckin}');
    Logger.info('SchedulePage', '  Draft: ${sampleSchedule.draft}');
    Logger.info('SchedulePage', '  Approved: ${sampleSchedule.approved}');

    var filteredList = schedules.where((schedule) {
      // Filter berdasarkan rentang tanggal jika ada
      if (_selectedDateRange != null && schedule.tglVisit.isNotEmpty) {
        try {
          final scheduleDate =
              DateFormat('yyyy-MM-dd').parse(schedule.tglVisit);
          final startDate = _selectedDateRange!.start;
          final endDate = _selectedDateRange!.end
              .add(const Duration(days: 1))
              .subtract(const Duration(seconds: 1));

          if (scheduleDate.isBefore(startDate) ||
              scheduleDate.isAfter(endDate)) {
            return false;
          }
        } catch (e) {
          Logger.error('SchedulePage',
              'Error parsing date for schedule ${schedule.id}: $e');
          return false;
        }
      }

      // Search matching
      final matchesSearch = query.isEmpty ||
          schedule.namaTujuan.toLowerCase().contains(searchQuery) ||
          (schedule.namaTipeSchedule ?? schedule.tipeSchedule)
              .toLowerCase()
              .contains(searchQuery) ||
          schedule.tglVisit.toLowerCase().contains(searchQuery) ||
          schedule.shift.toLowerCase().contains(searchQuery);

      if (!matchesSearch) {
        return false;
      }

      // Filter matching
      final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
      final lowerDraft = schedule.draft.toLowerCase().trim();

      if (_selectedFilter == l10n.filterAll) {
        return true;
      }

      bool matches = false;
      switch (_selectedFilter) {
        case 'Menunggu Persetujuan':
          matches =
              (schedule.approved == 0 && !lowerDraft.contains('rejected')) ||
                  ((lowerStatus == 'check-out' ||
                          lowerStatus == 'selesai' ||
                          lowerStatus == 'detail') &&
                      (schedule.realisasiApprove == null ||
                          schedule.realisasiApprove == 0));
          break;
        case 'Check-in':
          matches = schedule.approved == 1 &&
              !lowerDraft.contains('rejected') &&
              lowerStatus == 'belum checkin';
          break;
        case 'Check-out':
          matches = schedule.approved == 1 &&
              !lowerDraft.contains('rejected') &&
              (lowerStatus == 'check-in' || lowerStatus == 'belum checkout');
          break;
        case 'Selesai':
          matches = (lowerStatus == 'check-out' ||
                  lowerStatus == 'selesai' ||
                  lowerStatus == 'detail') &&
              schedule.realisasiApprove == 1;
          break;
        case 'Ditolak':
          matches = lowerDraft.contains('rejected');
          break;
      }

      return matches;
    }).toList()
      ..sort((a, b) {
        if (a.tglVisit.isEmpty && b.tglVisit.isEmpty) return 0;
        if (a.tglVisit.isEmpty) return 1;
        if (b.tglVisit.isEmpty) return -1;
        return b.tglVisit.compareTo(a.tglVisit);
      });

    Logger.info('SchedulePage', '===== FILTER RESULTS =====');
    Logger.info('SchedulePage',
        'Total schedules after filtering: ${filteredList.length}');

    return filteredList;
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      Logger.info('SchedulePage', '===== DATE RANGE PICKED =====');
      Logger.info('SchedulePage', 'Start: ${picked.start.toIso8601String()}');
      Logger.info('SchedulePage', 'End: ${picked.end.toIso8601String()}');

      setState(() {
        _selectedDateRange = picked;
      });

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // Refresh data normal dan filter secara lokal
        context.read<ScheduleBloc>().add(
              GetSchedulesEvent(userId: authState.user.idUser),
            );
      }
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      Logger.info('SchedulePage', 'Clearing date range and refreshing data');
      context.read<ScheduleBloc>().add(
            GetSchedulesEvent(userId: authState.user.idUser),
          );
    }
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: Theme.of(context).primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _pickDateRange,
          icon: Icon(
            Icons.date_range,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          label: Text(
            _selectedDateRange != null
                ? "${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}"
                : 'Pilih Rentang Tanggal',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        if (_selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Menampilkan jadwal:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _clearDateRange,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    "${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Logger.info('SchedulePage', '===== BUILD METHOD =====');
    Logger.info('SchedulePage', 'Selected date range: $_selectedDateRange');
    Logger.info('SchedulePage', 'Selected filter: $_selectedFilter');
    Logger.info('SchedulePage', 'Search query: ${_searchController.text}');

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 0.0),
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
                  _buildDateRangeFilter(),
                  const SizedBox(height: 12),
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
                                    });
                                  },
                                  color: Colors.grey[600],
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 8),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {});
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
                          _buildFilterChip('Menunggu Persetujuan'),
                          _buildFilterChip('Check-in'),
                          _buildFilterChip('Check-out'),
                          _buildFilterChip('Selesai'),
                          _buildFilterChip('Ditolak'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    Logger.info('SchedulePage', '===== AUTH STATE =====');
                    Logger.info(
                        'SchedulePage', 'Auth state: ${authState.runtimeType}');

                    if (authState is AuthAuthenticated) {
                      return BlocConsumer<ScheduleBloc, ScheduleState>(
                        listener: (context, state) {
                          _currentState = state;
                          if (state is ScheduleLoaded) {
                            setState(() {
                              _currentPage = state.currentPage;
                              _isLoadingMore = false;
                            });
                          }
                        },
                        builder: (context, state) {
                          Logger.info(
                              'SchedulePage', '===== SCHEDULE STATE =====');
                          Logger.info('SchedulePage', 'Schedule state: $state');

                          if (state is ScheduleLoading && _currentPage == 1) {
                            return const ShimmerScheduleListLoading();
                          } else if (state is ScheduleLoaded) {
                            final filteredSchedules = _getFilteredSchedules(
                              state.schedules,
                              _searchController.text,
                            );
                            Logger.info('SchedulePage',
                                'Filtered schedules count: ${filteredSchedules.length}');

                            if (filteredSchedules.isEmpty) {
                              return _buildEmptyState();
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                _searchController.clear();
                                setState(() {
                                  _selectedFilter = l10n.filterAll;
                                  _currentPage = 1;
                                });
                                context.read<ScheduleBloc>().add(
                                      GetSchedulesEvent(
                                          userId: authState.user.idUser),
                                    );
                              },
                              child: ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filteredSchedules.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < filteredSchedules.length) {
                                    return _buildScheduleCard(
                                        context, filteredSchedules[index]);
                                  } else {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          } else if (state is ScheduleError) {
                            return _buildErrorState(
                                context, authState, state.message);
                          }
                          return const SizedBox();
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
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
              GetSchedulesEvent(userId: authState.user.idUser),
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

  Color _getStatusColor(
      String status, String draft, int approved, int? realisasiApprove) {
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    if (lowerDraft.contains('rejected')) {
      return Colors.red.shade700;
    }

    if (approved == 0) {
      return Colors.orange.shade700;
    }

    if (approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if (lowerStatus == 'detail' &&
          (realisasiApprove == null || realisasiApprove == 0)) {
        return Colors.orange.shade700;
      }

      if (lowerStatus == 'check-out' || lowerStatus == 'selesai') {
        return realisasiApprove == 1
            ? Colors.teal.shade700
            : Colors.orange.shade700;
      }

      if (lowerStatus == 'belum checkin') {
        return Colors.blue.shade700;
      }

      if (lowerStatus == 'check-in' || lowerStatus == 'belum checkout') {
        return Colors.green.shade700;
      }
    }

    return Colors.grey.shade700;
  }

  String _getStatusText(
      String status, String draft, int approved, int? realisasiApprove) {
    final l10n = AppLocalizations.of(context)!;
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    // Cek status ditolak terlebih dahulu
    if (lowerDraft.contains('rejected')) {
      return l10n.rejected;
    }

    // Cek status menunggu persetujuan
    if (approved == 0) {
      return l10n.pendingApproval;
    }

    // Untuk jadwal yang sudah disetujui
    if (approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if (lowerStatus == 'detail' &&
          (realisasiApprove == null || realisasiApprove == 0)) {
        return l10n.pendingApproval;
      }

      // Jika sudah check-out atau selesai, cek realisasi
      if (lowerStatus == 'check-out' || lowerStatus == 'selesai') {
        if (realisasiApprove == 1) {
          return l10n.completed;
        }
        return l10n.pendingApproval; // Menunggu persetujuan realisasi
      }

      // Status check-in dan check-out
      if (lowerStatus == 'belum checkin') {
        return 'Check-in';
      } else if (lowerStatus == 'check-in' || lowerStatus == 'belum checkout') {
        return 'Check-out';
      }
    }

    return status;
  }

  IconData _getStatusIcon(
      String status, String draft, int approved, int? realisasiApprove) {
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    if (lowerDraft.contains('rejected')) {
      return Icons.cancel_outlined;
    }

    if (approved == 0) {
      return Icons.pending_outlined;
    }

    if (approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if (lowerStatus == 'detail' &&
          (realisasiApprove == null || realisasiApprove == 0)) {
        return Icons.pending_outlined;
      }

      if (lowerStatus == 'check-out' || lowerStatus == 'selesai') {
        return realisasiApprove == 1
            ? Icons.check_circle_outlined
            : Icons.pending_outlined;
      }

      if (lowerStatus == 'belum checkin') {
        return Icons.login_outlined;
      }

      if (lowerStatus == 'check-in' || lowerStatus == 'belum checkout') {
        return Icons.logout_outlined;
      }
    }

    return Icons.help_outline;
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule) {
    final lowerDraft = schedule.draft.toLowerCase().trim();
    final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: lowerDraft.contains('rejected')
            ? Border.all(color: Colors.red.shade200, width: 1.5)
            : Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: lowerDraft.contains('rejected')
                ? Colors.red.withOpacity(isDark ? 0.2 : 0.08)
                : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                                      .withOpacity(isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: lowerDraft.contains('rejected')
                                      ? Colors.red.shade100
                                          .withOpacity(isDark ? 0.3 : 0.5)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(isDark ? 0.3 : 0.15),
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
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
                        color: _getStatusColor(lowerStatus, lowerDraft,
                                schedule.approved, schedule.realisasiApprove)
                            .withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(lowerStatus, lowerDraft,
                                schedule.approved, schedule.realisasiApprove),
                            size: 16,
                            color: _getStatusColor(lowerStatus, lowerDraft,
                                schedule.approved, schedule.realisasiApprove),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(lowerStatus, lowerDraft,
                                schedule.approved, schedule.realisasiApprove),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(lowerStatus, lowerDraft,
                                  schedule.approved, schedule.realisasiApprove),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        customColor ?? Theme.of(context).textTheme.bodyMedium?.color;

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
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getFilterColor() {
      switch (label) {
        case 'Menunggu Persetujuan':
          return Colors.orange.shade700;
        case 'Check-in':
          return Colors.blue.shade700;
        case 'Check-out':
          return Colors.green.shade700;
        case 'Selesai':
          return Colors.teal.shade700;
        case 'Ditolak':
          return Colors.red.shade700;
        default:
          return Theme.of(context).primaryColor;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : l10n.filterAll;
          });
        },
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        selectedColor: getFilterColor().withOpacity(0.2),
        checkmarkColor: getFilterColor(),
        labelStyle: GoogleFonts.poppins(
          color: isSelected
              ? getFilterColor()
              : isDark
                  ? Colors.white
                  : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? getFilterColor() : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
