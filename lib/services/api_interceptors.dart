import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging interceptor for debugging API requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 📡 REQUEST');
    debugPrint(
      '├─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ Method: ${options.method}');
    debugPrint('│ URL: ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ Query Parameters: ${options.queryParameters}');
    }
    if (options.headers.isNotEmpty) {
      debugPrint('│ Headers: ${options.headers}');
    }
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 📥 RESPONSE');
    debugPrint(
      '├─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ Status Code: ${response.statusCode}');
    debugPrint('│ URL: ${response.requestOptions.uri}');
    debugPrint('│ Data Length: ${response.data.toString().length} bytes');
    if (response.data is Map && response.data['data'] is List) {
      debugPrint('│ Items Count: ${response.data['data'].length}');
    }
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '┌─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ 💥 ERROR');
    debugPrint(
      '├─────────────────────────────────────────────────────────────',
    );
    debugPrint('│ Type: ${err.type}');
    debugPrint('│ Message: ${err.message}');
    debugPrint('│ URL: ${err.requestOptions.uri}');
    if (err.response != null) {
      debugPrint('│ Status Code: ${err.response?.statusCode}');
      debugPrint('│ Response Data: ${err.response?.data}');
    }
    debugPrint(
      '└─────────────────────────────────────────────────────────────',
    );
    super.onError(err, handler);
  }
}

/// Retry interceptor for handling failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on specific error types
    if (!_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    // Get retry count from request options
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      debugPrint('│ ⚠️  Max retries ($maxRetries) reached');
      return super.onError(err, handler);
    }

    // Calculate delay with exponential backoff
    final delay = initialDelay * (retryCount + 1);
    debugPrint(
      '│ 🔄 Retrying request (${retryCount + 1}/$maxRetries) after ${delay.inSeconds}s...',
    );

    await Future.delayed(delay);

    // Update retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    // Retry the request
    try {
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return super.onError(e, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors, timeouts, and server errors (5xx)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Rate limit interceptor for Jikan API (2 requests per second to be safe)
class RateLimitInterceptor extends Interceptor {
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 500);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        debugPrint('│ ⏱️  Rate limiting: waiting ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
    super.onRequest(options, handler);
  }
}
