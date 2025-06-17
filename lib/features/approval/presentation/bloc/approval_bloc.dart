import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/success_message.dart';
import '../../domain/entities/approval.dart';
import '../../domain/entities/approval_filter.dart';
import '../../domain/entities/monthly_approval.dart';
import '../../domain/repositories/approval_repository.dart';

part 'approval_event.dart';
part 'approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final ApprovalRepository repository;

  ApprovalBloc({required this.repository}) : super(ApprovalInitial()) {
    on<GetApprovals>(_onGetApprovals);
    on<GetMonthlyApprovals>(_onGetMonthlyApprovals);
    on<FilterApprovals>(_onFilterApprovals);
    on<ApproveRequest>(_onApproveRequest);
    on<RejectRequest>(_onRejectRequest);
    on<SendApproval>(_onSendApproval);
    on<BatchApproveRequest>(_onBatchApproveRequest);
  }

  Future<void> _onGetApprovals(
    GetApprovals event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await repository.getApprovals(event.userId);
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (approvals) => emit(ApprovalLoaded(approvals: approvals)),
    );
  }

  Future<void> _onGetMonthlyApprovals(
    GetMonthlyApprovals event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await repository.getMonthlyApprovals(event.userId);
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (approvals) => emit(MonthlyApprovalLoaded(approvals: approvals)),
    );
  }

  Future<void> _onFilterApprovals(
    FilterApprovals event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final filter = ApprovalFilter(
      searchQuery: event.searchQuery,
      month: event.month,
      year: event.year,
      status: event.status,
      userId: event.userId,
    );
    final result = await repository.filterApprovals(filter);
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (approvals) => emit(ApprovalLoaded(approvals: approvals)),
    );
  }

  Future<void> _onApproveRequest(
    ApproveRequest event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result =
        await repository.approveRequest(event.approvalId, event.notes);
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (_) {
        SuccessMessage.show(
          context: event.context,
          message: 'Persetujuan berhasil dikirim',
          onDismissed: () {
            // Navigate back to approval list page
            Navigator.of(event.context).popUntil((route) {
              return route.settings.name == '/approval_list' || route.isFirst;
            });
            // Refresh the list after showing success message
            if (state is ApprovalLoaded) {
              final currentState = state as ApprovalLoaded;
              if (currentState.approvals.isNotEmpty) {
                add(GetApprovals(userId: currentState.approvals.first.idBawahan));
              }
            }
          },
        );
        // Emit loading state while refreshing
        emit(ApprovalLoading());
      },
    );
  }

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await repository.rejectRequest(
      event.idSchedule,
      event.idRejecter,
      event.comment,
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (_) {
        SuccessMessage.show(
          context: event.context,
          message: 'Penolakan berhasil dikirim',
          onDismissed: () {
            // Navigate back to approval list page
            Navigator.of(event.context).popUntil((route) {
              return route.settings.name == '/approval_list' || route.isFirst;
            });
            // Refresh the list after showing success message
            add(GetApprovals(userId: int.parse(event.idRejecter)));
          },
        );
        // Emit loading state while refreshing
        emit(ApprovalLoading());
      },
    );
  }

  Future<void> _onSendApproval(
    SendApproval event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await repository.sendApproval(
      event.scheduleId,
      event.userId,
      isApproved: event.isApproved,
      joinScheduleId: event.joinScheduleId,
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (response) {
        emit(ApprovalSuccess(message: response.message));
        add(GetApprovals(userId: event.userId)); // Refresh the list
      },
    );
  }

  Future<void> _onBatchApproveRequest(
    BatchApproveRequest event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await repository.batchApproveRequest(
      event.scheduleIds,
      event.notes,
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (_) {
        SuccessMessage.show(
          context: event.context,
          message: 'Persetujuan berhasil dikirim',
          onDismissed: () {
            if (state is ApprovalLoaded) {
              final currentState = state as ApprovalLoaded;
              if (currentState.approvals.isNotEmpty) {
                add(GetApprovals(userId: currentState.approvals.first.idBawahan));
              }
            }
          },
        );
        // Emit loading state while refreshing
        emit(ApprovalLoading());
      },
    );
  }
}
