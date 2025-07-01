import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/kpi_model.dart';
import '../../domain/entities/kpi_member.dart';
import '../../domain/usecases/get_kpi_member_data_usecase.dart';

// Events
abstract class KpiMemberEvent extends Equatable {
  const KpiMemberEvent();

  @override
  List<Object?> get props => [];
}

class LoadKpiMemberData extends KpiMemberEvent {
  final String year;
  final String month;
  final String? searchQuery;

  const LoadKpiMemberData({
    required this.year,
    required this.month,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [year, month, searchQuery];
}

class SearchKpiMember extends KpiMemberEvent {
  final String query;

  const SearchKpiMember(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class KpiMemberState extends Equatable {
  const KpiMemberState();

  @override
  List<Object?> get props => [];
}

class KpiMemberInitial extends KpiMemberState {}

class KpiMemberLoading extends KpiMemberState {}

class KpiMemberLoaded extends KpiMemberState {
  final List<KpiMember> kpiMembers;
  final String currentYear;
  final String currentMonth;
  final String? searchQuery;

  const KpiMemberLoaded({
    required this.kpiMembers,
    required this.currentYear,
    required this.currentMonth,
    this.searchQuery,
  });

  @override
  List<Object?> get props =>
      [kpiMembers, currentYear, currentMonth, searchQuery];
}

class KpiMemberError extends KpiMemberState {
  final String message;

  const KpiMemberError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class KpiMemberBloc extends Bloc<KpiMemberEvent, KpiMemberState> {
  final GetKpiMemberDataUseCase getKpiMemberDataUseCase;

  KpiMemberBloc({
    required this.getKpiMemberDataUseCase,
  }) : super(KpiMemberInitial()) {
    on<LoadKpiMemberData>(_onLoadKpiMemberData);
    on<SearchKpiMember>(_onSearchKpiMember);
  }

  Future<void> _onLoadKpiMemberData(
    LoadKpiMemberData event,
    Emitter<KpiMemberState> emit,
  ) async {
    try {
      debugPrint(
          'KPI Member Bloc: Loading data for ${event.year}-${event.month}');
      emit(KpiMemberLoading());

      final result = await getKpiMemberDataUseCase(
        KpiMemberParams(
          year: event.year,
          month: event.month,
        ),
      );

      await result.fold(
        (failure) async {
          debugPrint('KPI Member Bloc: Error - ${failure.toString()}');
          emit(KpiMemberError(failure.toString()));
        },
        (data) async {
          debugPrint('KPI Member Bloc: Loaded ${data.length} KPI members');
          var filteredData =
              event.searchQuery != null && event.searchQuery!.isNotEmpty
                  ? data
                      .where((kpiMember) => kpiMember.kodeRayon
                          .toLowerCase()
                          .contains(event.searchQuery!.toLowerCase()))
                      .toList()
                  : data;

          // Sort berdasarkan total nilai tertinggi
          filteredData.sort((a, b) {
            final totalNilaiA = _calculateTotalNilai(a.grafik);
            final totalNilaiB = _calculateTotalNilai(b.grafik);
            return totalNilaiB.compareTo(totalNilaiA); // Descending order
          });

          emit(KpiMemberLoaded(
            kpiMembers: filteredData,
            currentYear: event.year,
            currentMonth: event.month,
            searchQuery: event.searchQuery,
          ));
        },
      );
    } catch (e) {
      debugPrint('KPI Member Bloc: Unexpected error - $e');
      emit(KpiMemberError(e.toString()));
    }
  }

  Future<void> _onSearchKpiMember(
    SearchKpiMember event,
    Emitter<KpiMemberState> emit,
  ) async {
    if (state is KpiMemberLoaded) {
      final currentState = state as KpiMemberLoaded;
      debugPrint('KPI Member Bloc: Searching with query "${event.query}"');
      emit(KpiMemberLoading());

      add(LoadKpiMemberData(
        year: currentState.currentYear,
        month: currentState.currentMonth,
        searchQuery: event.query,
      ));
    }
  }

  double _calculateTotalNilai(List<KpiGrafik> grafik) {
    double total = 0;
    for (var item in grafik) {
      total += double.tryParse(item.data.nilai) ?? 0.0;
    }
    return total;
  }
}
