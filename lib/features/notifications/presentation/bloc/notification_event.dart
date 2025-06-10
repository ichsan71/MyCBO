abstract class NotificationEvent {
  const NotificationEvent();
}

class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

class ToggleScheduleNotifications extends NotificationEvent {
  const ToggleScheduleNotifications();
}

class ToggleApprovalNotifications extends NotificationEvent {
  const ToggleApprovalNotifications();
}
