class ServerException implements Exception {
  final String message;

  ServerException({this.message = 'Terjadi kesalahan pada server'});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Tidak ada koneksi internet'});

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({this.message = 'Autentikasi gagal'});

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(
      {this.message = 'Sesi telah berakhir. Silakan login kembali'});

  @override
  String toString() => message;
}
