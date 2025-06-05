part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();

  @override
  List<Object> get props => [];
}

class NotificationSettingsInitial extends NotificationSettingsState {}

class NotificationSettingsLoading extends NotificationSettingsState {}

class NotificationSettingsLoaded extends NotificationSettingsState {
  final NotificationSettings settings;

  const NotificationSettingsLoaded({required this.settings});

  @override
  List<Object> get props => [settings];
}

class NotificationSettingsError extends NotificationSettingsState {
  final String message;

  const NotificationSettingsError({required this.message});

  @override
  List<Object> get props => [message];
}
