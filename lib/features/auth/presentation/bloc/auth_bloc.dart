import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../../../features/notifications/presentation/bloc/notification_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final NotificationBloc notificationBloc;
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.notificationBloc,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
  }

  Future<void> _updateUsername(String username) async {
    try {
      logger.d('Updating username in notification settings: $username');
      notificationBloc.add(UpdateUsername(username));
      logger.i('Username update event dispatched to notification bloc');
    } catch (e) {
      logger.e('Error dispatching username update event: $e');
    }
  }

  Future<void> _onLoginEvent(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async => emit(AuthError(failure.toString())),
      (user) async {
        await _updateUsername(user.name);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutEvent(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase(NoParams());

    await result.fold(
      (failure) async => emit(AuthError(failure.toString())),
      (_) async {
        await _updateUsername('');
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase(NoParams());

    await result.fold(
      (failure) async => emit(const AuthUnauthenticated()),
      (user) async {
        await _updateUsername(user.name);
        emit(AuthAuthenticated(user));
      },
    );
  }
}
