import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<ToggleCheckoutNotification>(_onToggleCheckoutNotification);
    on<ToggleDailyGreetingNotification>(_onToggleDailyGreetingNotification);
    on<ToggleScheduleNotifications>(_onToggleScheduleNotifications);
    on<ToggleApprovalNotifications>(_onToggleApprovalNotifications);
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());
      final settingsEither = await repository.getNotificationSettings();

      void handleFailure(failure) {
        emit(NotificationError(
          message: failure.message,
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ));
      }

      void handleSuccess(settings) {
        emit(NotificationSettingsLoaded.fromSettings(settings));
      }

      settingsEither.fold(handleFailure, handleSuccess);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        isCheckoutEnabled: state.isCheckoutEnabled,
        isDailyGreetingEnabled: state.isDailyGreetingEnabled,
        userName: state.userName,
        lastCheckoutCheck: state.lastCheckoutCheck,
        lastDailyGreeting: state.lastDailyGreeting,
      ));
    }
  }

  Future<void> _onToggleCheckoutNotification(
    ToggleCheckoutNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final settingsEither = await repository.saveNotificationSettings(
        NotificationSettings(
          isCheckoutEnabled: event.enabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ),
      );

      void handleFailure(failure) {
        emit(NotificationError(
          message: failure.message,
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ));
      }

      void handleSuccess(_) {
        _loadNotificationSettings(emit);
      }

      settingsEither.fold(handleFailure, handleSuccess);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        isCheckoutEnabled: state.isCheckoutEnabled,
        isDailyGreetingEnabled: state.isDailyGreetingEnabled,
        userName: state.userName,
        lastCheckoutCheck: state.lastCheckoutCheck,
        lastDailyGreeting: state.lastDailyGreeting,
      ));
    }
  }

  Future<void> _onToggleDailyGreetingNotification(
    ToggleDailyGreetingNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final settingsEither = await repository.saveNotificationSettings(
        NotificationSettings(
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: event.enabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ),
      );

      void handleFailure(failure) {
        emit(NotificationError(
          message: failure.message,
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ));
      }

      void handleSuccess(_) {
        _loadNotificationSettings(emit);
      }

      settingsEither.fold(handleFailure, handleSuccess);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        isCheckoutEnabled: state.isCheckoutEnabled,
        isDailyGreetingEnabled: state.isDailyGreetingEnabled,
        userName: state.userName,
        lastCheckoutCheck: state.lastCheckoutCheck,
        lastDailyGreeting: state.lastDailyGreeting,
      ));
    }
  }

  Future<void> _onToggleScheduleNotifications(
    ToggleScheduleNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final settingsEither = await repository.saveNotificationSettings(
        NotificationSettings(
          isCheckoutEnabled: !state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ),
      );

      void handleFailure(failure) {
        emit(NotificationError(
          message: failure.message,
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ));
      }

      void handleSuccess(settings) {
        emit(NotificationSettingsLoaded.fromSettings(settings));
      }

      settingsEither.fold(handleFailure, handleSuccess);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        isCheckoutEnabled: state.isCheckoutEnabled,
        isDailyGreetingEnabled: state.isDailyGreetingEnabled,
        userName: state.userName,
        lastCheckoutCheck: state.lastCheckoutCheck,
        lastDailyGreeting: state.lastDailyGreeting,
      ));
    }
  }

  Future<void> _onToggleApprovalNotifications(
    ToggleApprovalNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final settingsEither = await repository.saveNotificationSettings(
        NotificationSettings(
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: !state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ),
      );

      void handleFailure(failure) {
        emit(NotificationError(
          message: failure.message,
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ));
      }

      void handleSuccess(settings) {
        emit(NotificationSettingsLoaded.fromSettings(settings));
      }

      settingsEither.fold(handleFailure, handleSuccess);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        isCheckoutEnabled: state.isCheckoutEnabled,
        isDailyGreetingEnabled: state.isDailyGreetingEnabled,
        userName: state.userName,
        lastCheckoutCheck: state.lastCheckoutCheck,
        lastDailyGreeting: state.lastDailyGreeting,
      ));
    }
  }

  Future<void> _loadNotificationSettings(Emitter<NotificationState> emit) async {
    try {
      final settingsEither = await repository.getNotificationSettings();

      void handleFailure(failure) {
        emit(NotificationError(
          message: failure.message,
          isCheckoutEnabled: state.isCheckoutEnabled,
          isDailyGreetingEnabled: state.isDailyGreetingEnabled,
          userName: state.userName,
          lastCheckoutCheck: state.lastCheckoutCheck,
          lastDailyGreeting: state.lastDailyGreeting,
        ));
      }

      void handleSuccess(settings) {
        emit(NotificationSettingsLoaded.fromSettings(settings));
      }

      settingsEither.fold(handleFailure, handleSuccess);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        isCheckoutEnabled: state.isCheckoutEnabled,
        isDailyGreetingEnabled: state.isDailyGreetingEnabled,
        userName: state.userName,
        lastCheckoutCheck: state.lastCheckoutCheck,
        lastDailyGreeting: state.lastDailyGreeting,
      ));
    }
  }
}
