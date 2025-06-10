import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_repository.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationEvent {}

class UpdateUsername extends NotificationEvent {
  final String username;

  const UpdateUsername(this.username);

  @override
  List<Object?> get props => [username];
}

class TestCheckoutNotification extends NotificationEvent {}

class TestDailyGreeting extends NotificationEvent {}

class ToggleCheckoutNotification extends NotificationEvent {
  final bool enabled;

  const ToggleCheckoutNotification(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDailyGreeting extends NotificationEvent {
  final bool enabled;

  const ToggleDailyGreeting(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class CheckNotificationStatus extends NotificationEvent {}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSettingsLoaded extends NotificationState {
  final NotificationSettings settings;
  final List<String> pendingCheckouts;
  final bool isWorking;

  const NotificationSettingsLoaded({
    required this.settings,
    required this.pendingCheckouts,
    required this.isWorking,
  });

  NotificationSettingsLoaded copyWith({
    NotificationSettings? settings,
    List<String>? pendingCheckouts,
    bool? isWorking,
  }) {
    return NotificationSettingsLoaded(
      settings: settings ?? this.settings,
      pendingCheckouts: pendingCheckouts ?? this.pendingCheckouts,
      isWorking: isWorking ?? this.isWorking,
    );
  }

  @override
  List<Object?> get props => [settings, pendingCheckouts, isWorking];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
      : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<UpdateUsername>(_onUpdateUsername);
    on<TestCheckoutNotification>(_onTestCheckoutNotification);
    on<TestDailyGreeting>(_onTestDailyGreeting);
    on<ToggleCheckoutNotification>(_onToggleCheckoutNotification);
    on<ToggleDailyGreeting>(_onToggleDailyGreeting);
    on<CheckNotificationStatus>(_onCheckNotificationStatus);

    // Auto-initialize when bloc is created
    add(InitializeNotifications());
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      // First check if notifications are working
      final isWorkingResult =
          await notificationRepository.isNotificationWorking();

      if (isWorkingResult.isLeft()) {
        emit(const NotificationError(
            'Failed to initialize notifications: Permission not granted'));
        return;
      }

      final isWorking = isWorkingResult.getOrElse(() => false);
      if (!isWorking) {
        emit(const NotificationError(
            'Failed to initialize notifications: Permission not granted'));
        return;
      }

      // Then get settings and pending checkouts
      final settingsResult =
          await notificationRepository.getNotificationSettings();
      final pendingCheckoutsResult =
          await notificationRepository.getPendingCheckouts();

      if (settingsResult.isRight() && pendingCheckoutsResult.isRight()) {
        final settings = settingsResult
            .getOrElse(() => throw Exception('Failed to get settings'));
        final pendingCheckouts = pendingCheckoutsResult.getOrElse(() => []);

        // Schedule notifications based on settings
        if (settings.isCheckoutEnabled) {
          await notificationRepository.scheduleCheckoutNotification();
        }
        if (settings.isDailyGreetingEnabled) {
          await notificationRepository.scheduleDailyGreeting();
        }

        emit(NotificationSettingsLoaded(
          settings: settings,
          pendingCheckouts: pendingCheckouts,
          isWorking: true,
        ));
      } else {
        emit(const NotificationError(
            'Failed to initialize notifications: Could not load settings'));
      }
    } catch (e) {
      emit(NotificationError(
          'Failed to initialize notifications: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSettingsLoaded) {
      try {
        final newSettings = currentState.settings.copyWith(
          userName: event.username,
        );
        final result =
            await notificationRepository.saveNotificationSettings(newSettings);
        if (result.isRight()) {
          emit(currentState.copyWith(settings: newSettings));
          // Re-schedule notifications with new username
          if (newSettings.isCheckoutEnabled) {
            await notificationRepository.scheduleCheckoutNotification();
          }
          if (newSettings.isDailyGreetingEnabled) {
            await notificationRepository.scheduleDailyGreeting();
          }
        }
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onTestCheckoutNotification(
    TestCheckoutNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationRepository.testCheckoutNotification();
    } catch (e) {
      emit(NotificationError(
          'Failed to test checkout notification: ${e.toString()}'));
    }
  }

  Future<void> _onTestDailyGreeting(
    TestDailyGreeting event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationRepository.testDailyGreeting();
    } catch (e) {
      emit(NotificationError('Failed to test daily greeting: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCheckoutNotification(
    ToggleCheckoutNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSettingsLoaded) {
      try {
        final newSettings = currentState.settings.copyWith(
          isCheckoutEnabled: event.enabled,
        );
        final result =
            await notificationRepository.saveNotificationSettings(newSettings);
        if (result.isRight()) {
          if (event.enabled) {
            await notificationRepository.scheduleCheckoutNotification();
          }
          emit(currentState.copyWith(settings: newSettings));
        }
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onToggleDailyGreeting(
    ToggleDailyGreeting event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSettingsLoaded) {
      try {
        final newSettings = currentState.settings.copyWith(
          isDailyGreetingEnabled: event.enabled,
        );
        final result =
            await notificationRepository.saveNotificationSettings(newSettings);
        if (result.isRight()) {
          if (event.enabled) {
            await notificationRepository.scheduleDailyGreeting();
          }
          emit(currentState.copyWith(settings: newSettings));
        }
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onCheckNotificationStatus(
    CheckNotificationStatus event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSettingsLoaded) {
      try {
        final pendingCheckoutsResult =
            await notificationRepository.getPendingCheckouts();
        final isWorkingResult =
            await notificationRepository.isNotificationWorking();

        if (pendingCheckoutsResult.isRight() && isWorkingResult.isRight()) {
          emit(NotificationSettingsLoaded(
            settings: currentState.settings,
            pendingCheckouts: pendingCheckoutsResult.getOrElse(() => []),
            isWorking: isWorkingResult.getOrElse(() => false),
          ));
        }
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }
}
