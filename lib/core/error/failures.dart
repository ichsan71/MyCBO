import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An unexpected error occurred'});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'Failure';
}

// General Failures
class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server error occurred'})
      : super(message: message);

  @override
  String toString() => message;
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache error occurred'})
      : super(message: message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network error occurred'})
      : super(message: message);

  @override
  String toString() => message;
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required String message}) : super(message: message);

  @override
  String toString() => message;
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = 'Authentication failed'})
      : super(message: message);

  @override
  String toString() => message;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required String message})
      : super(message: message);

  @override
  String toString() => message;
}

class ValidationFailure extends Failure {
  const ValidationFailure({String message = 'Validation error occurred'})
      : super(message: message);
}

class NotificationFailure extends Failure {
  const NotificationFailure({String message = 'Notification error occurred'})
      : super(message: message);
}
