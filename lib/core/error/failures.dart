import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'Failure';
}

// General Failures
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);

  @override
  String toString() => message;
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Tidak ada koneksi internet'])
      : super(message);

  @override
  String toString() => message;
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required String message}) : super(message);

  @override
  String toString() => message;
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = 'Autentikasi gagal'})
      : super(message);

  @override
  String toString() => message;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required String message}) : super(message);

  @override
  String toString() => message;
}
