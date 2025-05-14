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
  const NetworkFailure() : super('Tidak ada koneksi internet');

  @override
  String toString() => message;
}

class AuthenticationFailure extends Failure {
  final String message;

  
  const AuthenticationFailure({this.message = 'Autentikasi gagal'}) : super(message);

  @override
  String toString() => message;
}
