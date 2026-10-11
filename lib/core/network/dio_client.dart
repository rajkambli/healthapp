import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio dio;

  DioClient({Dio? customDio}) {
    dio = customDio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) {
          final mappedException = _mapDioException(err);
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: mappedException,
            ),
          );
        },
      ),
    );
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return const NetworkException('Connection timed out or network is unavailable.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final statusMessage = error.response?.statusMessage ?? 'Server returned error $statusCode';
        return ServerException(statusMessage, statusCode?.toString());
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkException('SSL certificate validation failed.');
      case DioExceptionType.unknown:
        return NetworkException(error.message ?? 'Network connection failed.');
    }
  }
}
