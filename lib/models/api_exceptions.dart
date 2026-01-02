/// Custom exception classes for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status: $statusCode)';
    }
    return 'ApiException: $message';
  }
}

/// Network connectivity issues
class NetworkException extends ApiException {
  NetworkException({String? message})
    : super(
        message:
            message ?? 'No internet connection. Please check your network.',
      );
}

/// Request timeout
class TimeoutException extends ApiException {
  TimeoutException({String? message})
    : super(message: message ?? 'Request timeout. Please try again.');
}

/// Server errors (5xx)
class ServerException extends ApiException {
  ServerException({String? message, int? statusCode, dynamic data})
    : super(
        message: message ?? 'Server error. Please try again later.',
        statusCode: statusCode,
        data: data,
      );
}

/// Client errors (4xx)
class ClientException extends ApiException {
  ClientException({String? message, int? statusCode, dynamic data})
    : super(
        message: message ?? 'Invalid request.',
        statusCode: statusCode,
        data: data,
      );
}

/// Rate limit exceeded
class RateLimitException extends ApiException {
  RateLimitException({String? message})
    : super(
        message: message ?? 'Rate limit exceeded. Please wait a moment.',
        statusCode: 429,
      );
}
