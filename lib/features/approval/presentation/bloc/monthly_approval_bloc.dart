import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/monthly_approval.dart';
import '../../domain/repositories/approval_repository.dart';

part 'monthly_approval_event.dart';
part 'monthly_approval_state.dart';

class MonthlyApprovalBloc
    extends Bloc<MonthlyApprovalEvent, MonthlyApprovalState> {
  final ApprovalRepository repository;

  MonthlyApprovalBloc({required this.repository})
      : super(MonthlyApprovalInitial()) {
    on<GetMonthlyApprovals>(_onGetMonthlyApprovals);
    on<SendMonthlyApproval>(_onSendMonthlyApproval);
  }

  Future<void> _onGetMonthlyApprovals(
    GetMonthlyApprovals event,
    Emitter<MonthlyApprovalState> emit,
  ) async {
    emit(MonthlyApprovalLoading());
    final result = await repository.getMonthlyApprovals(event.userId);
    result.fold(
      (failure) => emit(MonthlyApprovalError(message: failure.message)),
      (approvals) => emit(MonthlyApprovalLoaded(approvals: approvals)),
    );
  }

  Future<void> _onSendMonthlyApproval(
    SendMonthlyApproval event,
    Emitter<MonthlyApprovalState> emit,
  ) async {
    try {
      emit(MonthlyApprovalLoading());

      final result = await repository.sendMonthlyApproval(
        scheduleIds: event.scheduleIds,
        scheduleJoinVisitIds: event.scheduleJoinVisitIds,
        userId: event.userId,
        userAtasanId: event.userAtasanId,
      );

      result.fold(
        (failure) => emit(MonthlyApprovalError(message: failure.message)),
        (message) => emit(MonthlyApprovalSuccess(message: message)),
      );
    } catch (e) {
      emit(MonthlyApprovalError(message: e.toString()));
    }
  }
}
