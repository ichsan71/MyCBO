import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/approval.dart';
import '../../domain/usecases/get_approvals.dart';
import '../../domain/usecases/send_approval.dart';
import 'approval_event.dart';
import 'approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  final GetApprovals getApprovals;
  final SendApproval sendApproval;

  ApprovalBloc({
    required this.getApprovals,
    required this.sendApproval,
  }) : super(ApprovalInitial()) {
    on<GetApprovalsEvent>(_onGetApprovals);
    on<SendApprovalEvent>(_onSendApproval);
  }

  Future<void> _onGetApprovals(
      GetApprovalsEvent event, Emitter<ApprovalState> emit) async {
    emit(ApprovalLoading());

    final failureOrApprovals = await getApprovals(Params(userId: event.userId));

    emit(failureOrApprovals.fold(
      (failure) => ApprovalError(message: _mapFailureToMessage(failure)),
      (approvals) => approvals.isEmpty
          ? ApprovalsEmpty()
          : ApprovalsLoaded(approvals: approvals),
    ));
  }

  Future<void> _onSendApproval(
      SendApprovalEvent event, Emitter<ApprovalState> emit) async {
    emit(ApprovalSending());

    final failureOrResponse = await sendApproval(SendApprovalParams(
      scheduleId: event.scheduleId,
      userId: event.userId,
      isApproved: event.isApproved,
    ));

    emit(failureOrResponse.fold(
      (failure) => ApprovalError(message: _mapFailureToMessage(failure)),
      (response) => ApprovalSent(response: response),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
