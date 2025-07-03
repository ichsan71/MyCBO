import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
import 'package:test_cbo/features/kpi/domain/usecases/get_kpi_data.dart';
import 'package:flutter/foundation.dart';

// Events
abstract class KpiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetKpiDataEvent extends KpiEvent {
  final String userId;
  final String year;
  final String month;

  GetKpiDataEvent(this.userId, this.year, this.month);

  @override
  List<Object> get props => [userId, year, month];
}

class ResetAndRefreshKpiDataEvent extends KpiEvent {
  final String userId;
  final String year;
  final String month;

  ResetAndRefreshKpiDataEvent(this.userId, this.year, this.month);

  @override
  List<Object> get props => [userId, year, month];
}

// States
abstract class KpiState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KpiInitial extends KpiState {}

class KpiLoading extends KpiState {}

class KpiLoaded extends KpiState {
  final KpiResponse kpiData;
  final String currentYear;
  final String currentMonth;

  KpiLoaded(this.kpiData, this.currentYear, this.currentMonth);

  @override
  List<Object?> get props => [kpiData, currentYear, currentMonth];
}

class KpiError extends KpiState {
  final String message;

  KpiError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class KpiBloc extends Bloc<KpiEvent, KpiState> {
  final GetKpiData getKpiData;
  String? _lastYear;
  String? _lastMonth;

  KpiBloc({required this.getKpiData}) : super(KpiInitial()) {
    on<GetKpiDataEvent>((event, emit) async {
      emit(KpiLoading());

      final result = await getKpiData(Params(
        userId: event.userId,
        year: event.year,
        month: event.month,
      ));

      result.fold(
        (failure) => emit(KpiError('Failed to load KPI data')),
        (data) {
          debugPrint(
              'KPI Bloc - GetKpiDataEvent - Data received for ${event.year}-${event.month}');
          _lastYear = event.year;
          _lastMonth = event.month;
          emit(KpiLoaded(data, event.year, event.month));
        },
      );
    });

    on<ResetAndRefreshKpiDataEvent>((event, emit) async {
      try {
        debugPrint(
            'KPI Bloc - ResetAndRefreshKpiDataEvent - Starting refresh for ${event.year}-${event.month}');

        // Reset state
        emit(KpiInitial());
        emit(KpiLoading());

        // Get fresh data
        final result = await getKpiData(Params(
          userId: event.userId,
          year: event.year,
          month: event.month,
        ));

        if (isClosed) return;

        result.fold(
          (failure) => emit(KpiError('Failed to load KPI data')),
          (data) {
            debugPrint(
                'KPI Bloc - ResetAndRefreshKpiDataEvent - Data received');
            // Update cache
            _lastYear = event.year;
            _lastMonth = event.month;

            // Emit new state
            emit(KpiLoaded(data, event.year, event.month));
          },
        );
      } catch (e) {
        debugPrint('KPI Bloc - ResetAndRefreshKpiDataEvent - Error: $e');
        if (!isClosed) {
          emit(KpiError('An unexpected error occurred'));
        }
      }
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
