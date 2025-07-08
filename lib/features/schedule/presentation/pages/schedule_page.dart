import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/schedule.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../widgets/schedule_card.dart';
import 'package:intl/intl.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class SchedulePage extends StatefulWidget {
  final int userId;
  final DateTimeRange? selectedDateRange;

  const SchedulePage({
    Key? key,
    required this.userId,
    this.selectedDateRange,
  }) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  final String _selectedFilter = '';
  final List<Schedule> _filteredSchedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    print('SchedulePage: Loading initial data...');
    if (widget.selectedDateRange != null) {
      final rangeDate = _formatDateRange(widget.selectedDateRange);
      print('SchedulePage: Using range date mode - $rangeDate');
      context.read<ScheduleBloc>().add(
            GetSchedulesByRangeDateEvent(
              userId: widget.userId,
              rangeDate: rangeDate,
              page: 1,
            ),
          );
    } else {
      print('SchedulePage: Using normal getSchedules mode');
      context.read<ScheduleBloc>().add(
            GetSchedulesEvent(userId: widget.userId),
          );
    }
  }

  void _onScroll() {
    // Cek apakah user sudah scroll sampai bawah
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 200px threshold
      final state = context.read<ScheduleBloc>().state;

      // Debug logging
      print('SchedulePage: Scroll triggered');
      print('Current state: ${state.runtimeType}');
      print('_isLoading: $_isLoading');

      // Hanya trigger load more jika:
      // 1. State adalah ScheduleLoaded (bukan ScheduleLoadingMore)
      // 2. Ada data lebih yang bisa di-load
      // 3. Tidak sedang loading
      // 4. Sedang dalam mode range date (bukan mode getSchedules biasa)
      if (state is ScheduleLoaded &&
          state.hasMoreData &&
          !_isLoading &&
          widget.selectedDateRange != null) {
        print('SchedulePage: Triggering load more...');
        setState(() => _isLoading = true);

        context.read<ScheduleBloc>().add(
              LoadMoreSchedulesEvent(
                userId: widget.userId,
                rangeDate: _formatDateRange(widget.selectedDateRange),
              ),
            );
      } else {
        print('SchedulePage: Load more conditions not met');
        if (state is! ScheduleLoaded) print('- State is not ScheduleLoaded');
        if (state is ScheduleLoaded && !state.hasMoreData)
          print('- No more data');
        if (_isLoading) print('- Already loading');
        if (widget.selectedDateRange == null) print('- Not in range date mode');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        // Debug logging untuk state transitions
        print('SchedulePage: State changed to ${state.runtimeType}');
        if (state is ScheduleLoaded) {
          print('- Schedules count: ${state.schedules.length}');
          print('- Has more data: ${state.hasMoreData}');
          print('- Current page: ${state.currentPage}');
        } else if (state is ScheduleLoadingMore) {
          print('- Current schedules: ${state.currentSchedules.length}');
        }

        // Hanya reset _isLoading pada ScheduleLoaded, ScheduleError, atau ScheduleEmpty
        if (state is ScheduleLoaded) {
          print('SchedulePage: Resetting _isLoading to false (ScheduleLoaded)');
          setState(() => _isLoading = false);
        } else if (state is ScheduleError) {
          print('SchedulePage: Resetting _isLoading to false (ScheduleError)');
          setState(() => _isLoading = false);
        } else if (state is ScheduleEmpty) {
          print('SchedulePage: Resetting _isLoading to false (ScheduleEmpty)');
          setState(() => _isLoading = false);
        } else if (state is ScheduleLoadingMore) {
          print('SchedulePage: Keeping _isLoading as is (ScheduleLoadingMore)');
        }
        // TIDAK reset _isLoading pada ScheduleLoadingMore karena masih dalam proses loading
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () async {
              if (widget.selectedDateRange != null) {
                context.read<ScheduleBloc>().add(
                      GetSchedulesByRangeDateEvent(
                        userId: widget.userId,
                        rangeDate: _formatDateRange(widget.selectedDateRange),
                        page: 1,
                      ),
                    );
              } else {
                context.read<ScheduleBloc>().add(
                      GetSchedulesEvent(userId: widget.userId),
                    );
              }
            },
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: _buildScheduleList(state),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAddSchedule(),
            backgroundColor: AppTheme.getPrimaryColor(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Schedule'),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            // Handle calendar action
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
        decoration: InputDecoration(
          hintText: 'Search schedules...',
          hintStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
          prefixIcon: Icon(Icons.search,
              color: AppTheme.getSecondaryTextColor(context)),
          filled: true,
          fillColor: AppTheme.getCardBackgroundColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppTheme.getPrimaryColor(context), width: 2),
          ),
        ),
        onChanged: (value) {
          // Handle search
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Add filter chips here
        ],
      ),
    );
  }

  Widget _buildScheduleList(ScheduleState state) {
    if (state is ScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ScheduleError) {
      return Center(child: Text(state.message));
    } else if (state is ScheduleEmpty) {
      return const Center(child: Text('No schedules found'));
    } else if (state is ScheduleLoadingMore) {
      // Tampilkan list existing dengan loading indicator di bawah
      return ListView.builder(
        controller: _scrollController,
        itemCount:
            state.currentSchedules.length + 1, // +1 untuk loading indicator
        itemBuilder: (context, index) {
          if (index == state.currentSchedules.length) {
            // Loading indicator di akhir list
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final schedule = state.currentSchedules[index];
          return ScheduleCard(
            schedule: schedule,
            onTap: () {
              // Navigate to schedule detail
              Navigator.pushNamed(
                context,
                '/schedule_detail',
                arguments: schedule,
              );
            },
          );
        },
      );
    } else if (state is ScheduleLoaded) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.schedules.length + (state.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.schedules.length) {
            return state.hasMoreData
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox();
          }
          final schedule = state.schedules[index];
          return ScheduleCard(
            schedule: schedule,
            onTap: () {
              // Navigate to schedule detail
              Navigator.pushNamed(
                context,
                '/schedule_detail',
                arguments: schedule,
              );
            },
          );
        },
      );
    }
    return const Center(child: Text('Something went wrong'));
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return '';
    final formatter = DateFormat('MM/dd/yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  // Fungsi untuk navigasi ke halaman tambah jadwal
  Future<void> _navigateToAddSchedule() async {
    // Navigasi ke halaman tambah jadwal dan tunggu hasil
    final result = await Navigator.pushNamed(context, '/add_schedule');

    // Jika kembali dengan hasil sukses, refresh jadwal
    if (result == true) {
      if (!mounted) return;
      _loadInitialData(); // Refresh data setelah menambah jadwal
    }
  }
}
