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
import '../../../../core/presentation/theme/app_theme.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '';
  DateTimeRange? _selectedDateRange;

  // List untuk mode default
  bool _isLoadingMore = false;
  int _currentPage = 1;

  // List untuk mode filter rentang tanggal
  List<Schedule> _filteredRangeSchedules = [];
  List<Schedule> _originalRangeSchedules = [];
  bool _isLoadingMoreFilter = false;
  int _currentFilterPage = 1;
  bool _hasMoreFilterData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ScheduleBloc>().add(
            GetSchedulesEvent(userId: authState.user.idUser),
          );
    }
  }

  void _onScroll() {
    // Pastikan scroll controller attached dan memiliki posisi
    if (!_scrollController.hasClients) return;

    // Debug logging
    print('AuthSchedulePage: Scroll triggered');
    print('- Selected date range: ${_selectedDateRange != null}');
    print('- Is loading more filter: $_isLoadingMoreFilter');
    print('- Has more filter data: $_hasMoreFilterData');
    print('- Filtered schedules count: ${_filteredRangeSchedules.length}');

    // Cek kondisi untuk load more data
    if (_selectedDateRange != null &&
        !_isLoadingMoreFilter &&
        _hasMoreFilterData &&
        _filteredRangeSchedules.isNotEmpty) {
      const threshold = 0.8;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      print('AuthSchedulePage: Scroll position check');
      print('- Current scroll: $currentScroll');
      print('- Max scroll: $maxScroll');
      print('- Threshold: ${maxScroll * threshold}');

      if (currentScroll >= maxScroll * threshold) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          print('AuthSchedulePage: Triggering load more...');
          print('- Current page: $_currentFilterPage');

          // Prevent multiple calls
          if (!_isLoadingMoreFilter) {
            setState(() {
              _isLoadingMoreFilter = true;
            });

            // Increment page and fetch data
            _currentFilterPage++;
            print('AuthSchedulePage: Requesting page $_currentFilterPage');

            context.read<ScheduleBloc>().add(
                  GetSchedulesByRangeDateEvent(
                    userId: authState.user.idUser,
                    rangeDate: _formatRangeDate(_selectedDateRange!),
                    page: _currentFilterPage,
                  ),
                );
          } else {
            print('AuthSchedulePage: Already loading more, skipping');
          }
        }
      } else {
        print('AuthSchedulePage: Scroll threshold not reached');
      }
    } else {
      print('AuthSchedulePage: Load more conditions not met');
      if (_selectedDateRange == null) print('- No date range selected');
      if (_isLoadingMoreFilter) print('- Already loading more');
      if (!_hasMoreFilterData) print('- No more data available');
      if (_filteredRangeSchedules.isEmpty) print('- No filtered schedules');
    }
  }

  void _applyFilters() {
    if (!mounted) return;

    setState(() {
      if (_originalRangeSchedules.isEmpty) {
        _filteredRangeSchedules = [];
        return;
      }

      var filtered = List<Schedule>.from(_originalRangeSchedules);

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchQuery = _searchController.text.toLowerCase();
        filtered = filtered
            .where((schedule) =>
                schedule.namaTujuan.toLowerCase().contains(searchQuery) ||
                (schedule.namaTipeSchedule ?? schedule.tipeSchedule)
                    .toLowerCase()
                    .contains(searchQuery) ||
                schedule.tglVisit.toLowerCase().contains(searchQuery) ||
                schedule.shift.toLowerCase().contains(searchQuery))
            .toList();
      }

      // Apply status filter
      final l10n = AppLocalizations.of(context)!;
      if (_selectedFilter.isNotEmpty && _selectedFilter != l10n.filterAll) {
        filtered = filtered.where((schedule) {
          final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
          final lowerDraft = schedule.draft.toLowerCase().trim();

          switch (_selectedFilter) {
            case 'Pending':
              return (schedule.approved == 0 &&
                      !lowerDraft.contains('rejected')) ||
                  ((lowerStatus == 'check-out' ||
                          lowerStatus == 'selesai' ||
                          lowerStatus == 'detail') &&
                      !ScheduleStatusHelper.isRealisasiApproved(
                          schedule.realisasiApprove));
            case 'Check-in':
              return schedule.approved == 1 &&
                  !lowerDraft.contains('rejected') &&
                  lowerStatus == 'belum checkin';
            case 'Check-out':
              return schedule.approved == 1 &&
                  !lowerDraft.contains('rejected') &&
                  (lowerStatus == 'check-in' ||
                      lowerStatus == 'belum checkout');
            case 'Selesai':
              return (lowerStatus == 'check-out' ||
                      lowerStatus == 'selesai' ||
                      lowerStatus == 'detail') &&
                  ScheduleStatusHelper.isRealisasiApproved(
                      schedule.realisasiApprove);
            case 'Ditolak':
              return lowerDraft.contains('rejected');
            default:
              return true;
          }
        }).toList();
      }

      // Sort by date
      filtered.sort((a, b) {
        if (a.tglVisit.isEmpty && b.tglVisit.isEmpty) return 0;
        if (a.tglVisit.isEmpty) return 1;
        if (b.tglVisit.isEmpty) return -1;
        return b.tglVisit.compareTo(a.tglVisit);
      });

      _filteredRangeSchedules = filtered;
    });
  }

  void _onFilterSelected(String filter) {
    if (!mounted) return;
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _onSearchChanged() {
    if (!mounted) return;
    _applyFilters();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _formatRangeDate(DateTimeRange range) {
    // Log tanggal yang dipilih untuk debugging
    Logger.info('SchedulePage', '''
====== Selected Date Range ======
Start Date: ${range.start}
End Date: ${range.end}
''');

    // Format tanggal sesuai format API (MM/dd/YYYY)
    final formattedStart = DateFormat('MM/dd/yyyy').format(range.start);
    final formattedEnd = DateFormat('MM/dd/yyyy').format(range.end);
    final formattedRange = '$formattedStart - $formattedEnd';

    Logger.info('SchedulePage', '''
====== Formatted Date Range ======
Formatted Range: $formattedRange
''');

    return formattedRange;
  }

  void _pickDateRange() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 1);

    Logger.info('SchedulePage', '''
====== Date Picker Configuration ======
First Date: $firstDate
Last Date: $lastDate
Current Selected Range: ${_selectedDateRange?.start} - ${_selectedDateRange?.end}
''');

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
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
      Logger.info('SchedulePage', '''
====== New Date Range Selected ======
Start: ${picked.start}
End: ${picked.end}
Formatted: ${_formatRangeDate(picked)}
''');

      setState(() {
        _selectedDateRange = picked;
        _filteredRangeSchedules = [];
        _originalRangeSchedules = [];
        _currentFilterPage = 1;
        _hasMoreFilterData = true;
        _isLoadingMoreFilter = false;
        _searchController.clear();
        _selectedFilter = AppLocalizations.of(context)!.filterAll;
      });

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final formattedRange = _formatRangeDate(picked);
        Logger.info('SchedulePage', '''
====== Sending Request to API ======
User ID: ${authState.user.idUser}
Date Range: $formattedRange
Page: 1
''');

        context.read<ScheduleBloc>().add(
              GetSchedulesByRangeDateEvent(
                userId: authState.user.idUser,
                rangeDate: formattedRange,
                page: 1,
              ),
            );
      }
    } else {
      Logger.info('SchedulePage', 'Date range selection cancelled');
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
      _filteredRangeSchedules = [];
      _originalRangeSchedules = [];
      _currentFilterPage = 1;
      _hasMoreFilterData = true;
      _isLoadingMoreFilter = false;
      _searchController.clear();
      _selectedFilter = AppLocalizations.of(context)!.filterAll;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ScheduleBloc>().add(
            GetSchedulesEvent(userId: authState.user.idUser),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        // Debug logging untuk state transitions
        print('AuthSchedulePage: State changed to ${state.runtimeType}');

        if (state is ScheduleLoaded) {
          print('AuthSchedulePage: ScheduleLoaded received');
          print('- Schedules count: ${state.schedules.length}');
          print('- Has more data: ${state.hasMoreData}');
          print('- Current page: ${state.currentPage}');

          if (_selectedDateRange != null) {
            print('AuthSchedulePage: Processing range date mode');
            print('- Current filter page: $_currentFilterPage');
            print(
                '- Current original schedules: ${_originalRangeSchedules.length}');

            setState(() {
              if (_currentFilterPage == 1) {
                // Reset data untuk rentang tanggal baru
                print('AuthSchedulePage: Resetting data for page 1');
                _originalRangeSchedules = List<Schedule>.from(state.schedules);
                _filteredRangeSchedules = List<Schedule>.from(state.schedules);
              } else {
                // PERBAIKAN: Jangan tambahkan data lagi karena state.schedules sudah berisi semua data
                // Yang lama sudah ada di bloc, yang baru sudah digabung dan deduplicated di bloc
                print(
                    'AuthSchedulePage: Updating data for page $_currentFilterPage');
                print(
                    'AuthSchedulePage: Using bloc data directly (already deduplicated)');
                _originalRangeSchedules = List<Schedule>.from(state.schedules);

                // Terapkan filter yang ada ke data yang sudah lengkap
                _applyFilters();
              }

              _isLoadingMoreFilter = false;
              _hasMoreFilterData = state.hasMoreData;

              print('AuthSchedulePage: Final counts:');
              print('- Original schedules: ${_originalRangeSchedules.length}');
              print('- Filtered schedules: ${_filteredRangeSchedules.length}');
              print('- Has more data: $_hasMoreFilterData');
            });
          } else {
            // Mode default tanpa rentang tanggal
            print('AuthSchedulePage: Processing default mode');
            setState(() {
              _isLoadingMore = false;
            });
          }
        } else if (state is ScheduleError) {
          print('AuthSchedulePage: ScheduleError received: ${state.message}');
          setState(() {
            _isLoadingMoreFilter = false;
            if (_currentFilterPage > 1) {
              _currentFilterPage--;
              print(
                  'AuthSchedulePage: Rolled back to page $_currentFilterPage');
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (state is ScheduleLoadingMore) {
          print('AuthSchedulePage: ScheduleLoadingMore received');
          print('- Current schedules: ${state.currentSchedules.length}');
          // Tidak perlu setState di sini karena loading indicator sudah ditangani di UI
        }
      },
      child: Scaffold(
        appBar: null,
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return FloatingActionButton(
                onPressed: () => _navigateToAddSchedule(),
                backgroundColor: AppTheme.getPrimaryColor(context),
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
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDateRangeFilter(),
                    const SizedBox(height: 12),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppTheme.getBorderColor(context)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getSecondaryTextColor(context)
                                .withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.getSecondaryTextColor(context),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getSurfaceColor(context),
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
                                    color:
                                        AppTheme.getSecondaryTextColor(context),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 8),
                          fillColor: AppTheme.getCardBackgroundColor(context),
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
                            _buildFilterChip('Pending'),
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
                      if (authState is AuthAuthenticated) {
                        return BlocBuilder<ScheduleBloc, ScheduleState>(
                          builder: (context, state) {
                            if (_selectedDateRange != null) {
                              // Mode filter range date
                              if (state is ScheduleLoading &&
                                  _currentFilterPage == 1) {
                                return const ShimmerScheduleListLoading();
                              }

                              if (_filteredRangeSchedules.isEmpty) {
                                return _buildEmptyState();
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  // Reset pagination state
                                  setState(() {
                                    _filteredRangeSchedules = [];
                                    _currentFilterPage = 1;
                                    _hasMoreFilterData = true;
                                    _isLoadingMoreFilter = false;
                                  });

                                  // Request data baru
                                  if (mounted) {
                                    context.read<ScheduleBloc>().add(
                                          GetSchedulesByRangeDateEvent(
                                            userId: authState.user.idUser,
                                            rangeDate: _formatRangeDate(
                                                _selectedDateRange!),
                                            page: 1,
                                          ),
                                        );
                                  }
                                },
                                child: ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: _filteredRangeSchedules.length +
                                      (_hasMoreFilterData ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index <
                                        _filteredRangeSchedules.length) {
                                      return _buildScheduleCard(
                                        context,
                                        _filteredRangeSchedules[index],
                                      );
                                    } else {
                                      // Tampilkan loading indicator jika ada more data dan sedang loading
                                      // atau placeholder jika ada more data tapi belum loading
                                      if (_hasMoreFilterData) {
                                        print(
                                            'AuthSchedulePage: Showing loading indicator - isLoading: $_isLoadingMoreFilter');
                                        return _isLoadingMoreFilter
                                            ? const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text(
                                                      'Scroll untuk load more...'),
                                                ),
                                              );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }
                                  },
                                ),
                              );
                            } else {
                              // Mode default
                              return _buildDefaultScheduleList(
                                  state, authState);
                            }
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
            color: AppTheme.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptySchedule,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noScheduleYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getSecondaryTextColor(context),
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

        // Reset semua state
        setState(() {
          _selectedFilter = AppLocalizations.of(context)!.filterAll;
          _searchController.clear();
          _currentPage = 1;
          _isLoadingMore = false;

          // Reset state untuk mode filter tanggal
          if (_selectedDateRange != null) {
            _filteredRangeSchedules = [];
            _originalRangeSchedules = [];
            _currentFilterPage = 1;
            _isLoadingMoreFilter = false;
            _hasMoreFilterData = true;
          }
        });

        // Refresh data sesuai mode yang aktif
        if (_selectedDateRange != null) {
          context.read<ScheduleBloc>().add(
                GetSchedulesByRangeDateEvent(
                  userId: authState.user.idUser,
                  rangeDate: _formatRangeDate(_selectedDateRange!),
                  page: 1,
                ),
              );
        } else {
          context.read<ScheduleBloc>().add(
                GetSchedulesEvent(userId: authState.user.idUser),
              );
        }
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
      String status, String draft, int approved, dynamic realisasiApprove) {
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    if (lowerDraft.contains('rejected')) {
      return AppTheme.getErrorColor(context);
    }

    if (approved == 0) {
      return AppTheme.getWarningColor(context);
    }

    if (approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if (lowerStatus == 'detail' &&
          !ScheduleStatusHelper.isRealisasiApproved(realisasiApprove)) {
        return AppTheme.getWarningColor(context);
      }

      if (lowerStatus == 'check-out' || lowerStatus == 'selesai') {
        return ScheduleStatusHelper.isRealisasiApproved(realisasiApprove)
            ? AppTheme.getTertiaryColor(context)
            : AppTheme.getWarningColor(context);
      }

      if (lowerStatus == 'belum checkin') {
        return AppTheme.getPrimaryColor(context);
      }

      if (lowerStatus == 'check-in' || lowerStatus == 'belum checkout') {
        return AppTheme.getSuccessColor(context);
      }
    }

    return AppTheme.getSecondaryTextColor(context);
  }

  String _getStatusText(
      String status, String draft, int approved, dynamic realisasiApprove) {
    final l10n = AppLocalizations.of(context)!;
    final lowerStatus = status.toLowerCase().trim();
    final lowerDraft = draft.toLowerCase().trim();

    // Cek status ditolak terlebih dahulu
    if (lowerDraft.contains('rejected')) {
      return l10n.rejected;
    }

    // Cek status menunggu persetujuan
    if (approved == 0) {
      return 'Pending';
    }

    // Untuk jadwal yang sudah disetujui
    if (approved == 1) {
      // Jika status check-in adalah detail dan realisasi belum disetujui
      if (lowerStatus == 'detail' &&
          !ScheduleStatusHelper.isRealisasiApproved(realisasiApprove)) {
        return 'Pending';
      }

      // Jika sudah check-out atau selesai, cek realisasi
      if (lowerStatus == 'check-out' || lowerStatus == 'selesai') {
        if (ScheduleStatusHelper.isRealisasiApproved(realisasiApprove)) {
          return l10n.completed;
        }
        return 'Pending'; // Menunggu persetujuan realisasi
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
      String status, String draft, int approved, dynamic realisasiApprove) {
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
          !ScheduleStatusHelper.isRealisasiApproved(realisasiApprove)) {
        return Icons.pending_outlined;
      }

      if (lowerStatus == 'check-out' || lowerStatus == 'selesai') {
        return ScheduleStatusHelper.isRealisasiApproved(realisasiApprove)
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
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: lowerDraft.contains('rejected')
            ? Border.all(
                color: AppTheme.getErrorColor(context).withOpacity(0.3),
                width: 1.5)
            : Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: lowerDraft.contains('rejected')
                ? AppTheme.getErrorColor(context)
                    .withOpacity(isDark ? 0.2 : 0.08)
                : AppTheme.getSecondaryTextColor(context)
                    .withOpacity(isDark ? 0.3 : 0.05),
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
                                  ? AppTheme.getErrorColor(context)
                                      .withOpacity(isDark ? 0.2 : 0.1)
                                  : AppTheme.getPrimaryColor(context)
                                      .withOpacity(isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: lowerDraft.contains('rejected')
                                      ? AppTheme.getErrorColor(context)
                                          .withOpacity(isDark ? 0.3 : 0.5)
                                      : AppTheme.getPrimaryColor(context)
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
                                  ? AppTheme.getErrorColor(context)
                                  : AppTheme.getPrimaryColor(context),
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
                                          ? AppTheme.getErrorColor(context)
                                          : AppTheme.getSuccessColor(context),
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
                    color: AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Tanggal:',
                        schedule.tglVisit,
                        lowerDraft.contains('rejected')
                            ? AppTheme.getErrorColor(context)
                            : AppTheme.getSecondaryTextColor(context),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.access_time,
                        'Shift:',
                        schedule.shift,
                        lowerDraft.contains('rejected')
                            ? Colors.red.shade400
                            : AppTheme.getSecondaryTextColor(context),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.medical_services_outlined,
                        'Spesialis:',
                        schedule.namaSpesialis?.isNotEmpty == true
                            ? schedule.namaSpesialis ?? '-'
                            : '-',
                        lowerDraft.contains('rejected')
                            ? AppTheme.getErrorColor(context)
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
                      color:
                          AppTheme.getPrimaryColor(context).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppTheme.getPrimaryColor(context).withOpacity(0.2),
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
                                  ? AppTheme.getErrorColor(context)
                                  : AppTheme.getPrimaryColor(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Produk:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: lowerDraft.contains('rejected')
                                    ? AppTheme.getErrorColor(context)
                                    : AppTheme.getPrimaryColor(context),
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
                                    color: AppTheme.getCardBackgroundColor(
                                        context),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: lowerDraft.contains('rejected')
                                          ? AppTheme.getErrorColor(context)
                                              .withOpacity(0.3)
                                          : AppTheme.getPrimaryColor(context)
                                              .withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.getSecondaryTextColor(
                                                context)
                                            .withOpacity(0.03),
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
                                          ? AppTheme.getErrorColor(context)
                                          : AppTheme.getPrimaryColor(context),
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
                      color: AppTheme.getSurfaceColor(context),
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
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          schedule.note,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.getSecondaryTextColor(context),
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
    final textColor = customColor ?? AppTheme.getPrimaryTextColor(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: customColor ?? AppTheme.getPrimaryColor(context),
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

    Color getFilterColor() {
      switch (label) {
        case 'Pending':
          return AppTheme.getWarningColor(context);
        case 'Check-in':
          return AppTheme.getPrimaryColor(context);
        case 'Check-out':
          return AppTheme.getSuccessColor(context);
        case 'Selesai':
          return AppTheme.getTertiaryColor(context);
        case 'Ditolak':
          return AppTheme.getErrorColor(context);
        default:
          return AppTheme.getPrimaryColor(context);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          _onFilterSelected(selected ? label : l10n.filterAll);
        },
        backgroundColor: AppTheme.getSurfaceColor(context),
        selectedColor: getFilterColor().withOpacity(0.2),
        checkmarkColor: getFilterColor(),
        labelStyle: GoogleFonts.poppins(
          color: isSelected
              ? getFilterColor()
              : AppTheme.getPrimaryTextColor(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? getFilterColor()
                : AppTheme.getBorderColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: AppTheme.getPrimaryColor(context)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _pickDateRange,
          icon: Icon(
            Icons.date_range,
            size: 20,
            color: AppTheme.getPrimaryColor(context),
          ),
          label: Text(
            _selectedDateRange != null
                ? _formatRangeDate(_selectedDateRange!)
                : 'Pilih Rentang Tanggal',
            style: TextStyle(
              color: AppTheme.getPrimaryColor(context),
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
                      color: AppTheme.getPrimaryColor(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Menampilkan jadwal:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _clearDateRange,
                      color: AppTheme.getPrimaryColor(context),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    _formatRangeDate(_selectedDateRange!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getPrimaryColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultScheduleList(
      ScheduleState state, AuthAuthenticated authState) {
    if (state is ScheduleLoading && _currentPage == 1) {
      return const ShimmerScheduleListLoading();
    } else if (state is ScheduleLoaded) {
      final filteredSchedules = _getFilteredSchedulesForDefault(
        state.schedules,
        _searchController.text,
      );
      if (filteredSchedules.isEmpty) {
        return _buildEmptyState();
      }
      return RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          setState(() {
            _selectedFilter = AppLocalizations.of(context)!.filterAll;
            _currentPage = 1;
          });
          if (mounted) {
            context.read<ScheduleBloc>().add(
                  GetSchedulesEvent(userId: authState.user.idUser),
                );
          }
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: filteredSchedules.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < filteredSchedules.length) {
              return _buildScheduleCard(context, filteredSchedules[index]);
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
      return _buildErrorState(context, authState, state.message);
    }
    return const SizedBox();
  }

  List<Schedule> _getFilteredSchedulesForDefault(
      List<Schedule> schedules, String query) {
    final l10n = AppLocalizations.of(context)!;
    if (schedules.isEmpty) return [];

    var filtered = List<Schedule>.from(schedules);

    // Apply search filter
    if (query.isNotEmpty) {
      final searchQuery = query.toLowerCase();
      filtered = filtered
          .where((schedule) =>
              schedule.namaTujuan.toLowerCase().contains(searchQuery) ||
              (schedule.namaTipeSchedule ?? schedule.tipeSchedule)
                  .toLowerCase()
                  .contains(searchQuery) ||
              schedule.tglVisit.toLowerCase().contains(searchQuery) ||
              schedule.shift.toLowerCase().contains(searchQuery))
          .toList();
    }

    // Apply status filter
    if (_selectedFilter.isNotEmpty && _selectedFilter != l10n.filterAll) {
      filtered = filtered.where((schedule) {
        final lowerStatus = schedule.statusCheckin.toLowerCase().trim();
        final lowerDraft = schedule.draft.toLowerCase().trim();

        switch (_selectedFilter) {
          case 'Pending':
            return (schedule.approved == 0 &&
                    !lowerDraft.contains('rejected')) ||
                ((lowerStatus == 'check-out' ||
                        lowerStatus == 'selesai' ||
                        lowerStatus == 'detail') &&
                    !ScheduleStatusHelper.isRealisasiApproved(
                        schedule.realisasiApprove));
          case 'Check-in':
            return schedule.approved == 1 &&
                !lowerDraft.contains('rejected') &&
                lowerStatus == 'belum checkin';
          case 'Check-out':
            return schedule.approved == 1 &&
                !lowerDraft.contains('rejected') &&
                (lowerStatus == 'check-in' || lowerStatus == 'belum checkout');
          case 'Selesai':
            return (lowerStatus == 'check-out' ||
                    lowerStatus == 'selesai' ||
                    lowerStatus == 'detail') &&
                ScheduleStatusHelper.isRealisasiApproved(
                    schedule.realisasiApprove);
          case 'Ditolak':
            return lowerDraft.contains('rejected');
          default:
            return true;
        }
      }).toList();
    }

    // Sort by date
    filtered.sort((a, b) {
      if (a.tglVisit.isEmpty && b.tglVisit.isEmpty) return 0;
      if (a.tglVisit.isEmpty) return 1;
      if (b.tglVisit.isEmpty) return -1;
      return b.tglVisit.compareTo(a.tglVisit);
    });

    return filtered;
  }
}
