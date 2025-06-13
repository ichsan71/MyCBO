import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../error/exceptions.dart';
import 'api_config.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null, // Accept all status codes
    ));

    // Add logging interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.info(
            'DioConfig', 'REQUEST[${options.method}] => PATH: ${options.path}');
        Logger.info('DioConfig', 'Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        Logger.info('DioConfig',
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');

        if (response.statusCode == 500) {
          final retryCount =
              response.requestOptions.extra['retryCount'] as int? ?? 0;
          if (retryCount < 3) {
            // Add exponential backoff
            await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));

            // Retry the request
            try {
              response.requestOptions.extra['retryCount'] = retryCount + 1;
              final retryResponse = await dio.fetch(response.requestOptions);
              return handler.resolve(retryResponse);
            } catch (e) {
              Logger.error('DioConfig', 'Retry attempt failed: $e');
              return handler.next(response);
            }
          }
        }

        // Check if response is a redirect
        if (response.statusCode == 302) {
          final location = response.headers.value('location');
          Logger.info('DioConfig', 'Redirect location: $location');

          if (location?.contains('/login') == true) {
            Logger.error(
                'DioConfig', 'Authentication redirect detected to login page');
            return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  error: 'Sesi login telah berakhir. Silakan login kembali.',
                  type: DioExceptionType.unknown,
                  response: response,
                ),
                true);
          }
        }

        // Check if response is HTML and contains login redirect
        if (response.data != null &&
            response.data is String &&
            (response.data as String).contains('Redirecting to') &&
            (response.data as String).contains('/login')) {
          Logger.error('DioConfig', 'HTML redirect to login page detected');
          return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: 'Sesi login telah berakhir. Silakan login kembali.',
                type: DioExceptionType.unknown,
                response: response,
              ),
              true);
        }

        return handler.next(response);
      },
      onError: (DioException e, handler) {
        Logger.error('DioConfig',
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        Logger.error('DioConfig',
            'Error details: ${e.error ?? "No error details available"}');
        Logger.error('DioConfig', 'Error type: ${e.type}');

        return handler.next(e);
      },
    ));

    return dio;
  }
}
