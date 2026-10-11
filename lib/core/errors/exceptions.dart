/// Base exception class for data sources.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.code]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection error', super.code]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred', super.code]);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission exception', super.code]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation exception', super.code]);
}
