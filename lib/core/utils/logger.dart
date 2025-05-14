import 'package:flutter/foundation.dart';

class Logger {
  static const String _infoPrefix = '📘 INFO';
  static const String _debugPrefix = '🔍 DEBUG';
  static const String _warningPrefix = '⚠️ WARNING';
  static const String _errorPrefix = '❌ ERROR';
  static const String _successPrefix = '✅ SUCCESS';
  static const String _networkPrefix = '🌐 NETWORK';

  static final Logger _instance = Logger._internal();

  factory Logger() {
    return _instance;
  }

  Logger._internal();

  static void info(String tag, String message) {
    if (kDebugMode) {
      print('$_infoPrefix [$tag] $message');
    }
  }

  static void debug(String tag, String message) {
    if (kDebugMode) {
      print('$_debugPrefix [$tag] $message');
    }
  }

  static void warning(String tag, String message) {
    if (kDebugMode) {
      print('$_warningPrefix [$tag] $message');
    }
  }

  static void error(String tag, String message,
      [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_errorPrefix [$tag] $message');
      if (error != null) {
        print('$_errorPrefix [$tag] Error details: $error');
      }
      if (stackTrace != null) {
        print('$_errorPrefix [$tag] Stack trace: $stackTrace');
      }
    }
  }

  static void success(String tag, String message) {
    if (kDebugMode) {
      print('$_successPrefix [$tag] $message');
    }
  }

  static void network(String tag, String message,
      {String? url, String? method, dynamic data, dynamic response}) {
    if (kDebugMode) {
      print('$_networkPrefix [$tag] $message');
      if (url != null) print('$_networkPrefix [$tag] URL: $url');
      if (method != null) print('$_networkPrefix [$tag] Method: $method');
      if (data != null) print('$_networkPrefix [$tag] Data: $data');
      if (response != null) print('$_networkPrefix [$tag] Response: $response');
    }
  }

  static void divider() {
    if (kDebugMode) {
      print('----------------------------------------');
    }
  }
}
