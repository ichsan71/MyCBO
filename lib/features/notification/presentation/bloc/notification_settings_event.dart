part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadNotificationSettings extends NotificationSettingsEvent {}

class UpdateNotificationSettings extends NotificationSettingsEvent {
  final NotificationSettings settings;

  const UpdateNotificationSettings({required this.settings});

  @override
  List<Object> get props => [settings];
}

class SendTestNotification extends NotificationSettingsEvent {
  const SendTestNotification();
}
