import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/approval.dart';
import '../../domain/entities/approval_filter.dart';
import '../../domain/entities/approval_response.dart';
import '../../domain/usecases/approve_request_usecase.dart';
import '../../domain/usecases/filter_approvals_usecase.dart';
import '../../domain/usecases/get_approvals_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';
import '../../domain/usecases/send_approval.dart';

part 'approval_event.dart';
part 'approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final GetApprovalsUseCase getApprovals;
  final FilterApprovalsUseCase filterApprovals;
  final ApproveRequestUseCase approveRequest;
  final RejectRequestUseCase rejectRequest;
  final SendApproval sendApproval;

  ApprovalBloc({
    required this.getApprovals,
    required this.filterApprovals,
    required this.approveRequest,
    required this.rejectRequest,
    required this.sendApproval,
  }) : super(ApprovalInitial()) {
    on<GetApprovalsEvent>(_onGetApprovals);
    on<FilterApprovalsEvent>(_onFilterApprovals);
    on<ApproveRequestEvent>(_onApproveRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<ApproveDetailEvent>(_onApproveDetail);
    on<RejectDetailEvent>(_onRejectDetail);
    on<SendApprovalEvent>(_onSendApproval);
  }

  Future<void> _onGetApprovals(
    GetApprovalsEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await getApprovals(GetApprovalsParams(userId: event.userId));
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (approvals) => emit(ApprovalLoaded(approvals: approvals)),
    );
  }

  Future<void> _onFilterApprovals(
    FilterApprovalsEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalLoading());
    final result = await filterApprovals(event.filter);
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (approvals) => emit(ApprovalLoaded(approvals: approvals)),
    );
  }

  Future<void> _onApproveRequest(
    ApproveRequestEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalProcessing());
    final result = await approveRequest(
      ApproveRequestParams(
        approvalId: event.approvalId,
        notes: event.notes,
      ),
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (_) => add(GetApprovalsEvent(userId: event.userId)),
    );
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalProcessing());
    final result = await rejectRequest(
      RejectRequestParams(
        idSchedule: event.idSchedule,
        idRejecter: event.idRejecter,
        comment: event.comment,
      ),
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (_) => emit(ApprovalInitial()),
    );
  }

  Future<void> _onApproveDetail(
    ApproveDetailEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalSending());
    final result = await sendApproval(
      SendApprovalParams(
        scheduleId: event.scheduleId,
        userId: event.userId,
        isApproved: true,
      ),
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (response) => emit(ApprovalSent(response: response)),
    );
  }

  Future<void> _onRejectDetail(
    RejectDetailEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalSending());
    final result = await sendApproval(
      SendApprovalParams(
        scheduleId: event.scheduleId,
        userId: event.userId,
        isApproved: false,
      ),
    );
    result.fold(
      (failure) => emit(ApprovalError(message: failure.message)),
      (response) => emit(ApprovalSent(response: response)),
    );
  }

  Future<void> _onSendApproval(
    SendApprovalEvent event,
    Emitter<ApprovalState> emit,
  ) async {
    emit(ApprovalSending());
    final result = await sendApproval(
      SendApprovalParams(
        scheduleId: event.scheduleId,
        userId: event.userId,
        isApproved: event.isApproved,
      ),
    );
    result.fold(
      (failure) => emit(ApprovalError(message: _mapFailureToMessage(failure))),
      (response) => emit(ApprovalSent(response: response)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Terjadi kesalahan pada server. Silakan coba lagi.';
      case NetworkFailure:
        return 'Tidak ada koneksi internet. Silakan periksa koneksi anda dan coba lagi.';
      default:
        return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
    }
  }
}
