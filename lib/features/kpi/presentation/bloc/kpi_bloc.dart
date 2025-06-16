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

  GetKpiDataEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class ResetAndRefreshKpiDataEvent extends KpiEvent {
  final String userId;

  ResetAndRefreshKpiDataEvent(this.userId);

  @override
  List<Object> get props => [userId];
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

  KpiLoaded(this.kpiData);

  @override
  List<Object?> get props => [kpiData];
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
  String? _lastUserId;
  KpiResponse? _lastResponse;

  KpiBloc({required this.getKpiData}) : super(KpiInitial()) {
    on<GetKpiDataEvent>((event, emit) async {
      emit(KpiLoading());
      
      final result = await getKpiData(Params(userId: event.userId));
      
      result.fold(
        (failure) => emit(KpiError('Failed to load KPI data')),
        (data) {
          // Debug print untuk memeriksa data
          debugPrint('KPI Bloc - Data received:');
          for (var item in data.data) {
            debugPrint('Grafik count: ${item.grafik.length}');
            for (var grafik in item.grafik) {
              debugPrint('Label: ${grafik.label}');
            }
          }
          
          _lastUserId = event.userId;
          _lastResponse = data;
          emit(KpiLoaded(data));
        },
      );
    });

    on<ResetAndRefreshKpiDataEvent>((event, emit) async {
      try {
        // Reset state and cache
        _lastResponse = null;
        _lastUserId = null;
        emit(KpiInitial());
        
        // Force a small delay to ensure UI updates
        await Future.delayed(const Duration(milliseconds: 100));
        emit(KpiLoading());
        
        // Get fresh data
        final result = await getKpiData(Params(userId: event.userId));
        
        if (isClosed) return;
        
        result.fold(
          (failure) => emit(KpiError('Failed to load KPI data')),
          (data) {
            // Only update if user ID matches current request
            if (event.userId == _lastUserId) {
              emit(KpiError('Data might be stale, retrying...'));
              add(ResetAndRefreshKpiDataEvent(event.userId));
              return;
            }
            
            // Store new data
            _lastUserId = event.userId;
            _lastResponse = data;
            
            // Emit fresh state with new data
            emit(KpiLoaded(data.copyWith(
              data: data.data.map((item) => item.copyWith(
                grafik: item.grafik.map((g) => g.copyWith()).toList(),
              )).toList(),
            )));
          },
        );
      } catch (e) {
        if (!isClosed) {
          emit(KpiError('An unexpected error occurred'));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _lastResponse = null;
    _lastUserId = null;
    return super.close();
  }
} 