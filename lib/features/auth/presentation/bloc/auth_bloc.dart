import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:logger/logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
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
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
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
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    logger.i('🔐 Checking auth status...');
    emit(const AuthLoading());

    try {
      final result = await getCurrentUserUseCase(NoParams());

      await result.fold(
        (failure) async {
          logger.w('🔐 Auth check failed: ${failure.toString()}');
          emit(const AuthUnauthenticated());
        },
        (user) async {
          logger.i('🔐 User authenticated: ${user.name}');
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      logger.e('🔐 Error during auth check: $e');
      emit(const AuthUnauthenticated());
    }
  }
}
