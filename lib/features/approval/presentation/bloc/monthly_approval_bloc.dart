import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/success_message.dart';
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
    emit(MonthlyApprovalLoading());
    final result = await repository.sendMonthlyApproval(
      scheduleIds: event.scheduleIds,
      scheduleJoinVisitIds: event.scheduleJoinVisitIds,
      userId: event.userId,
      userAtasanId: event.userAtasanId,
      isRejected: event.isRejected,
      comment: event.comment,
    );
    result.fold(
      (failure) => emit(MonthlyApprovalError(message: failure.message)),
      (message) {
        // Show success message
        SuccessMessage.show(
          context: event.context,
          message: event.isRejected 
              ? 'Penolakan berhasil dikirim'
              : 'Persetujuan berhasil dikirim',
          onDismissed: () {
            // Navigate back to approval list page
            Navigator.of(event.context).popUntil((route) {
              return route.settings.name == '/approval_list' || route.isFirst;
            });
            // Refresh the list after showing success message
            add(GetMonthlyApprovals(userId: event.userId));
          },
        );
        // Emit loading state while refreshing
        emit(MonthlyApprovalLoading());
      },
    );
  }
}
