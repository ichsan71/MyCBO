import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool isCheckoutReminderEnabled;
  final bool isApprovalNotificationEnabled;
  final bool isVisitRealizationEnabled;
  final String morningGreetingTime; // Format: HH:mm
  final String checkoutReminderStartTime; // Format: HH:mm
  final int checkoutReminderInterval; // Interval dalam jam

  const NotificationSettings({
    required this.isCheckoutReminderEnabled,
    required this.isApprovalNotificationEnabled,
    required this.isVisitRealizationEnabled,
    required this.morningGreetingTime,
    required this.checkoutReminderStartTime,
    required this.checkoutReminderInterval,
  });

  @override
  List<Object?> get props => [
        isCheckoutReminderEnabled,
        isApprovalNotificationEnabled,
        isVisitRealizationEnabled,
        morningGreetingTime,
        checkoutReminderStartTime,
        checkoutReminderInterval,
      ];

  NotificationSettings copyWith({
    bool? isCheckoutReminderEnabled,
    bool? isApprovalNotificationEnabled,
    bool? isVisitRealizationEnabled,
    String? morningGreetingTime,
    String? checkoutReminderStartTime,
    int? checkoutReminderInterval,
  }) {
    return NotificationSettings(
      isCheckoutReminderEnabled:
          isCheckoutReminderEnabled ?? this.isCheckoutReminderEnabled,
      isApprovalNotificationEnabled:
          isApprovalNotificationEnabled ?? this.isApprovalNotificationEnabled,
      isVisitRealizationEnabled:
          isVisitRealizationEnabled ?? this.isVisitRealizationEnabled,
      morningGreetingTime: morningGreetingTime ?? this.morningGreetingTime,
      checkoutReminderStartTime:
          checkoutReminderStartTime ?? this.checkoutReminderStartTime,
      checkoutReminderInterval:
          checkoutReminderInterval ?? this.checkoutReminderInterval,
    );
  }
}
