import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool isCheckoutEnabled;
  final bool isDailyGreetingEnabled;
  final String userName;
  final DateTime lastCheckoutCheck;
  final DateTime lastDailyGreeting;

  const NotificationSettings({
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

  NotificationSettings copyWith({
    bool? isCheckoutEnabled,
    bool? isDailyGreetingEnabled,
    String? userName,
    DateTime? lastCheckoutCheck,
    DateTime? lastDailyGreeting,
  }) {
    return NotificationSettings(
      isCheckoutEnabled: isCheckoutEnabled ?? this.isCheckoutEnabled,
      isDailyGreetingEnabled:
          isDailyGreetingEnabled ?? this.isDailyGreetingEnabled,
      userName: userName ?? this.userName,
      lastCheckoutCheck: lastCheckoutCheck ?? this.lastCheckoutCheck,
      lastDailyGreeting: lastDailyGreeting ?? this.lastDailyGreeting,
    );
  }
}
