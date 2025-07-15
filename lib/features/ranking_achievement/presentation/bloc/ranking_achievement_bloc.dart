import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/features/ranking_achievement/domain/entities/ranking_achievement_entity.dart';
import 'package:test_cbo/features/ranking_achievement/domain/usecases/get_ranking_achievement.dart';
import 'package:flutter/foundation.dart';

// Events
abstract class RankingAchievementEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetRankingAchievementEvent extends RankingAchievementEvent {
  final String roleId;
  final String selectedMonth;

  GetRankingAchievementEvent(this.roleId, this.selectedMonth);

  @override
  List<Object> get props => [roleId, selectedMonth];
}

class RefreshRankingAchievementEvent extends RankingAchievementEvent {
  final String roleId;
  final String selectedMonth;

  RefreshRankingAchievementEvent(this.roleId, this.selectedMonth);

  @override
  List<Object> get props => [roleId, selectedMonth];
}

// States
abstract class RankingAchievementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RankingAchievementInitial extends RankingAchievementState {}

class RankingAchievementLoading extends RankingAchievementState {}

class RankingAchievementLoaded extends RankingAchievementState {
  final List<RankingAchievementEntity> rankings;
  final String selectedMonth;
  final int currentUserId;
  final List<RankingAchievementEntity> sortedRankings;
  final List<RankingAchievementEntity> displayRankings;

  RankingAchievementLoaded({
    required this.rankings,
    required this.selectedMonth,
    required this.currentUserId,
  })  : sortedRankings = _sortRankings(rankings, selectedMonth, currentUserId),
        displayRankings =
            _createDisplayRankings(rankings, selectedMonth, currentUserId);

  static List<RankingAchievementEntity> _sortRankings(
    List<RankingAchievementEntity> rankings,
    String selectedMonth,
    int currentUserId,
  ) {
    // Create a copy of the rankings list
    final sortedList = List<RankingAchievementEntity>.from(rankings);

    // Sort by achievement value for the selected month (descending)
    sortedList.sort((a, b) {
      final aValue =
          double.tryParse(a.monthlyAchievements[selectedMonth] ?? '0') ?? 0.0;
      final bValue =
          double.tryParse(b.monthlyAchievements[selectedMonth] ?? '0') ?? 0.0;
      return bValue.compareTo(aValue); // Descending order
    });

    return sortedList;
  }

  static List<RankingAchievementEntity> _createDisplayRankings(
    List<RankingAchievementEntity> rankings,
    String selectedMonth,
    int currentUserId,
  ) {
    // First, sort by achievement value
    final sortedList = _sortRankings(rankings, selectedMonth, currentUserId);

    // Find current user's position in the sorted list
    final currentUserIndex =
        sortedList.indexWhere((user) => user.idUser == currentUserId);

    if (currentUserIndex == -1) {
      // Current user not found, return all items
      return sortedList;
    }

    // Create display list with current user at top, then all others
    final displayList = <RankingAchievementEntity>[];

    // Add current user first
    displayList.add(sortedList[currentUserIndex]);

    // Add all other users (excluding current user)
    for (int i = 0; i < sortedList.length; i++) {
      if (i != currentUserIndex) {
        displayList.add(sortedList[i]);
      }
    }

    return displayList;
  }

  @override
  List<Object?> get props =>
      [rankings, selectedMonth, currentUserId, sortedRankings, displayRankings];
}

class RankingAchievementError extends RankingAchievementState {
  final String message;

  RankingAchievementError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class RankingAchievementBloc
    extends Bloc<RankingAchievementEvent, RankingAchievementState> {
  final GetRankingAchievement getRankingAchievement;

  RankingAchievementBloc({required this.getRankingAchievement})
      : super(RankingAchievementInitial()) {
    on<GetRankingAchievementEvent>((event, emit) async {
      emit(RankingAchievementLoading());

      final result = await getRankingAchievement(Params(roleId: event.roleId));

      result.fold(
        (failure) => emit(
            RankingAchievementError('Failed to load ranking achievement data')),
        (rankings) {
          debugPrint(
              'RankingAchievement Bloc - Data received for month: ${event.selectedMonth}');
          emit(RankingAchievementLoaded(
            rankings: rankings,
            selectedMonth: event.selectedMonth,
            currentUserId: int.tryParse(event.roleId) ?? 0,
          ));
        },
      );
    });

    on<RefreshRankingAchievementEvent>((event, emit) async {
      try {
        debugPrint(
            'RankingAchievement Bloc - Refreshing data for month: ${event.selectedMonth}');

        // Reset state
        emit(RankingAchievementInitial());
        emit(RankingAchievementLoading());

        // Get fresh data
        final result =
            await getRankingAchievement(Params(roleId: event.roleId));

        if (isClosed) return;

        result.fold(
          (failure) => emit(RankingAchievementError(
              'Failed to load ranking achievement data')),
          (rankings) {
            debugPrint('RankingAchievement Bloc - Refresh completed');
            emit(RankingAchievementLoaded(
              rankings: rankings,
              selectedMonth: event.selectedMonth,
              currentUserId: int.tryParse(event.roleId) ?? 0,
            ));
          },
        );
      } catch (e) {
        debugPrint('RankingAchievement Bloc - Refresh error: $e');
        if (!isClosed) {
          emit(RankingAchievementError('An unexpected error occurred'));
        }
      }
    });
  }
}
