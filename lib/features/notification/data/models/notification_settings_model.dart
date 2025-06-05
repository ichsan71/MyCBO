import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_settings.dart';

class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.isCheckoutReminderEnabled,
    required super.isApprovalNotificationEnabled,
    required super.isVisitRealizationEnabled,
    required super.morningGreetingTime,
    required super.checkoutReminderStartTime,
    required super.checkoutReminderInterval,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      isCheckoutReminderEnabled: json['isCheckoutReminderEnabled'] ?? true,
      isApprovalNotificationEnabled:
          json['isApprovalNotificationEnabled'] ?? true,
      isVisitRealizationEnabled: json['isVisitRealizationEnabled'] ?? true,
      morningGreetingTime: json['morningGreetingTime'] ?? '08:00',
      checkoutReminderStartTime: json['checkoutReminderStartTime'] ?? '08:00',
      checkoutReminderInterval: json['checkoutReminderInterval'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCheckoutReminderEnabled': isCheckoutReminderEnabled,
      'isApprovalNotificationEnabled': isApprovalNotificationEnabled,
      'isVisitRealizationEnabled': isVisitRealizationEnabled,
      'morningGreetingTime': morningGreetingTime,
      'checkoutReminderStartTime': checkoutReminderStartTime,
      'checkoutReminderInterval': checkoutReminderInterval,
    };
  }

  factory NotificationSettingsModel.fromEntity(NotificationSettings settings) {
    return NotificationSettingsModel(
      isCheckoutReminderEnabled: settings.isCheckoutReminderEnabled,
      isApprovalNotificationEnabled: settings.isApprovalNotificationEnabled,
      isVisitRealizationEnabled: settings.isVisitRealizationEnabled,
      morningGreetingTime: settings.morningGreetingTime,
      checkoutReminderStartTime: settings.checkoutReminderStartTime,
      checkoutReminderInterval: settings.checkoutReminderInterval,
    );
  }
}
