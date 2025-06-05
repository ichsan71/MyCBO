import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/notification_repository.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class ShowApprovalNotification extends NotificationEvent {
  final int scheduleId;
  final String message;

  const ShowApprovalNotification({
    required this.scheduleId,
    required this.message,
  });

  @override
  List<Object?> get props => [scheduleId, message];
}

class ShowVisitRealizationNotification extends NotificationEvent {
  final int scheduleId;
  final String message;

  const ShowVisitRealizationNotification({
    required this.scheduleId,
    required this.message,
  });

  @override
  List<Object?> get props => [scheduleId, message];
}

class RequestNotificationPermission extends NotificationEvent {}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationSuccess extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationPermissionGranted extends NotificationState {}

class NotificationPermissionDenied extends NotificationState {}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
      : super(NotificationInitial()) {
    on<ShowApprovalNotification>(_onShowApprovalNotification);
    on<ShowVisitRealizationNotification>(_onShowVisitRealizationNotification);
    on<RequestNotificationPermission>(_onRequestNotificationPermission);
  }

  Future<void> _onShowApprovalNotification(
    ShowApprovalNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.showApprovalNotification(
      event.scheduleId,
      event.message,
    );

    result.fold(
      (failure) => emit(NotificationError(
          message: 'Gagal menampilkan notifikasi persetujuan')),
      (_) => emit(NotificationSuccess()),
    );
  }

  Future<void> _onShowVisitRealizationNotification(
    ShowVisitRealizationNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result =
        await notificationRepository.showVisitRealizationNotification(
      event.scheduleId,
      event.message,
    );

    result.fold(
      (failure) => emit(
          NotificationError(message: 'Gagal menampilkan notifikasi realisasi')),
      (_) => emit(NotificationSuccess()),
    );
  }

  Future<void> _onRequestNotificationPermission(
    RequestNotificationPermission event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.initializeNotifications();

    result.fold(
      (failure) => emit(NotificationPermissionDenied()),
      (_) => emit(NotificationPermissionGranted()),
    );
  }
}
