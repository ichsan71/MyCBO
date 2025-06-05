import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/usecases/get_notification_settings.dart';
import '../../domain/usecases/save_notification_settings.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/local_notification_service.dart';

part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

class NotificationSettingsBloc
    extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  final GetNotificationSettings getNotificationSettings;
  final SaveNotificationSettings saveNotificationSettings;
  final LocalNotificationService notificationService;

  NotificationSettingsBloc({
    required this.getNotificationSettings,
    required this.saveNotificationSettings,
    required this.notificationService,
  }) : super(NotificationSettingsInitial()) {
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<SendTestNotification>(_onSendTestNotification);
  }

  Future<void> _onLoadNotificationSettings(
    LoadNotificationSettings event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(NotificationSettingsLoading());
    final result = await getNotificationSettings(NoParams());
    result.fold(
      (failure) =>
          emit(NotificationSettingsError(message: 'Gagal memuat pengaturan')),
      (settings) => emit(NotificationSettingsLoaded(settings: settings)),
    );
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(NotificationSettingsLoading());
    final result = await saveNotificationSettings(
      SaveNotificationSettingsParams(settings: event.settings),
    );
    result.fold(
      (failure) => emit(
          NotificationSettingsError(message: 'Gagal menyimpan pengaturan')),
      (_) => emit(NotificationSettingsLoaded(settings: event.settings)),
    );
  }

  Future<void> _onSendTestNotification(
    SendTestNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await notificationService.showTestNotification();
    } catch (e) {
      emit(
          NotificationSettingsError(message: 'Gagal mengirim notifikasi test'));
    }
  }
}
