import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cbo/features/kpi/data/models/kpi_model.dart';
import 'package:test_cbo/features/kpi/domain/usecases/get_kpi_data.dart';

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

  KpiBloc({required this.getKpiData}) : super(KpiInitial()) {
    on<GetKpiDataEvent>((event, emit) async {
      emit(KpiLoading());
      
      final result = await getKpiData(Params(userId: event.userId));
      
      result.fold(
        (failure) => emit(KpiError('Failed to load KPI data')),
        (data) => emit(KpiLoaded(data)),
      );
    });
  }
} 