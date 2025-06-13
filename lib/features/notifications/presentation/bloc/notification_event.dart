abstract class NotificationEvent {
  const NotificationEvent();
}

class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

class ToggleCheckoutNotification extends NotificationEvent {
  final bool enabled;
  const ToggleCheckoutNotification({required this.enabled});
}

class ToggleDailyGreetingNotification extends NotificationEvent {
  final bool enabled;
  const ToggleDailyGreetingNotification({required this.enabled});
}

class ToggleScheduleNotifications extends NotificationEvent {
  const ToggleScheduleNotifications();
}

class ToggleApprovalNotifications extends NotificationEvent {
  const ToggleApprovalNotifications();
}
