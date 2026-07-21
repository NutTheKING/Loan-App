import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final responseData = error.response?.data;
    final message = responseData is Map<String, dynamic>
        ? responseData['message'] as String? ??
              'The server could not complete your request.'
        : error.message ?? 'A network error occurred. Please try again.';
    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
    );
  }

  @override
  String toString() => message;
}
