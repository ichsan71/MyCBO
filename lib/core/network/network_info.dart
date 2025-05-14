import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:test_cbo/core/utils/logger.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    final connected = await connectionChecker.hasConnection;
    Logger.info('network_info', '🌐 NetworkInfo: Status koneksi internet = ${connected ? 'TERHUBUNG' : 'TIDAK TERHUBUNG'}');
    return connected;
  }
}
