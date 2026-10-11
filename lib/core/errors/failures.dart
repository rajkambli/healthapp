import 'package:equatable/equatable.dart';

/// Base sealed Failure class for the domain and presentation layers.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Represents failures related to network unavailability or timeouts.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection available.', super.code]);
}

/// Represents HTTP failures, 4xx/5xx responses, or API service errors.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server encountered an error. Please try again.', super.code]);
}

/// Represents Hive read/write or data corruption failures.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load or persist local data.', super.code]);
}

/// Represents permission denials (e.g., activity recognition or notifications).
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Required permission was denied.', super.code]);
}

/// Represents validation errors (e.g. invalid sleep session time bounds).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Input data validation failed.', super.code]);
}

/// Represents uncaught or unexpected failures.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.', super.code]);
}
