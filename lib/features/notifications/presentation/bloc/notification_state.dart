import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_settings.dart';

abstract class NotificationState extends Equatable {
  final bool isCheckoutEnabled;
  final bool isDailyGreetingEnabled;
  final String userName;
  final DateTime lastCheckoutCheck;
  final DateTime lastDailyGreeting;

  const NotificationState({
    required this.isCheckoutEnabled,
    required this.isDailyGreetingEnabled,
    required this.userName,
    required this.lastCheckoutCheck,
    required this.lastDailyGreeting,
  });

  @override
  List<Object?> get props => [
        isCheckoutEnabled,
        isDailyGreetingEnabled,
        userName,
        lastCheckoutCheck,
        lastDailyGreeting,
      ];
}

class NotificationInitial extends NotificationState {
  NotificationInitial()
      : super(
          isCheckoutEnabled: false,
          isDailyGreetingEnabled: false,
          userName: '',
          lastCheckoutCheck: DateTime.now(),
          lastDailyGreeting: DateTime.now(),
        );
}

class NotificationLoading extends NotificationState {
  NotificationLoading()
      : super(
          isCheckoutEnabled: false,
          isDailyGreetingEnabled: false,
          userName: '',
          lastCheckoutCheck: DateTime.now(),
          lastDailyGreeting: DateTime.now(),
        );
}

class NotificationSettingsLoaded extends NotificationState {
  const NotificationSettingsLoaded({
    required bool isCheckoutEnabled,
    required bool isDailyGreetingEnabled,
    required String userName,
    required DateTime lastCheckoutCheck,
    required DateTime lastDailyGreeting,
  }) : super(
          isCheckoutEnabled: isCheckoutEnabled,
          isDailyGreetingEnabled: isDailyGreetingEnabled,
          userName: userName,
          lastCheckoutCheck: lastCheckoutCheck,
          lastDailyGreeting: lastDailyGreeting,
        );

  factory NotificationSettingsLoaded.fromSettings(NotificationSettings settings) {
    return NotificationSettingsLoaded(
      isCheckoutEnabled: settings.isCheckoutEnabled,
      isDailyGreetingEnabled: settings.isDailyGreetingEnabled,
      userName: settings.userName,
      lastCheckoutCheck: settings.lastCheckoutCheck,
      lastDailyGreeting: settings.lastDailyGreeting,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({
    required this.message,
    required bool isCheckoutEnabled,
    required bool isDailyGreetingEnabled,
    required String userName,
    required DateTime lastCheckoutCheck,
    required DateTime lastDailyGreeting,
  }) : super(
          isCheckoutEnabled: isCheckoutEnabled,
          isDailyGreetingEnabled: isDailyGreetingEnabled,
          userName: userName,
          lastCheckoutCheck: lastCheckoutCheck,
          lastDailyGreeting: lastDailyGreeting,
        );

  @override
  List<Object?> get props => [...super.props, message];
}
