import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/schedule.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../widgets/schedule_card.dart';
import 'package:intl/intl.dart';

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
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = context.read<ScheduleBloc>().state;
      if (state is ScheduleLoaded && state.hasMoreData && !_isLoading) {
        setState(() => _isLoading = true);
        context.read<ScheduleBloc>().add(
              LoadMoreSchedulesEvent(
                userId: widget.userId,
                rangeDate: _formatDateRange(widget.selectedDateRange),
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleLoaded || state is ScheduleLoadingMore) {
          setState(() => _isLoading = false);
        }
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
            onPressed: () {
              // Handle add schedule
            },
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
        decoration: const InputDecoration(
          hintText: 'Search schedules...',
          prefixIcon: Icon(Icons.search),
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
    } else if (state is ScheduleLoaded) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.schedules.length + (state.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.schedules.length) {
            return state.hasMoreData
                ? const Center(child: CircularProgressIndicator())
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
}
