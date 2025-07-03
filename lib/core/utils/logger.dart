import 'package:flutter/foundation.dart';

class Logger {
  static const String _debugPrefix = '🔍 DEBUG';
  static const String _networkPrefix = '🌐 NETWORK';

  static final Logger _instance = Logger._internal();

  factory Logger() {
    return _instance;
  }

  Logger._internal();

  static void info(String tag, String message) {
    if (kDebugMode) {
      print('ℹ️ $tag: $message');
    }
  }

  static void debug(String tag, String message) {
    if (kDebugMode) {
      print('$_debugPrefix [$tag] $message');
    }
  }

  static void warning(String tag, String message) {
    if (kDebugMode) {
      print('⚠️ $tag: $message');
    }
  }

  static void error(String tag, String message, [dynamic details]) {
    if (kDebugMode) {
      print('❌ $tag: $message');
      if (details != null) {
        print('❌ Details: $details');
      }
    }
  }

  static void success(String tag, String message) {
    if (kDebugMode) {
      print('✅ $tag: $message');
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

  static void api(String method, String endpoint,
      {dynamic body, dynamic response}) {
    if (kDebugMode) {
      print('🌐 API $method: $endpoint');
      if (body != null) {
        print('📤 Request Body: $body');
      }
      if (response != null) {
        print('📥 Response: $response');
      }
    }
  }
}
