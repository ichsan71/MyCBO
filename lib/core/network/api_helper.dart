import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:test_cbo/core/network/api_config.dart';
import 'package:test_cbo/core/utils/logger.dart';

class ApiHelper {
  static Future<http.Response> retryRequest(
    Future<http.Response> Function() request, {
    int maxRetries = ApiConfig.maxRetries,
    Duration retryDelay = ApiConfig.retryDelay,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        final response = await request();

        // Log response details
        Logger.info(
            'ApiHelper',
            'Request attempt $attempts - Status: ${response.statusCode}\n'
                'URL: ${response.request?.url}\n'
                'Headers: ${response.request?.headers}\n'
                'Response: ${response.body}');

        // If response is successful or we've reached max retries, return it
        if (response.statusCode < 500 || attempts >= maxRetries) {
          return response;
        }

        // If we get here, it means we got a 5xx error and should retry
        Logger.warning('ApiHelper',
            'Got ${response.statusCode} status code. Retrying in ${retryDelay.inSeconds}s...');
      } catch (e) {
        // If this was our last attempt, rethrow the error
        if (attempts >= maxRetries) {
          Logger.error(
              'ApiHelper', 'Request failed after $attempts attempts: $e');
          rethrow;
        }

        Logger.warning(
            'ApiHelper',
            'Request attempt $attempts failed: $e\n'
                'Retrying in ${retryDelay.inSeconds}s...');
      }

      // Wait before retrying
      await Future.delayed(retryDelay);
    }
  }

  static Future<bool> isServerReachable() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.baseUrl),
            headers: ApiConfig.getHeaders(null),
          )
          .timeout(ApiConfig.connectTimeout);

      return response.statusCode < 500;
    } catch (e) {
      Logger.error('ApiHelper', 'Server reachability check failed: $e');
      return false;
    }
  }
}
