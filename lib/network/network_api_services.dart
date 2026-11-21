import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkApiServices {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Map<String, dynamic>> getApi(String url) async {
    try {
      final response = await _dio.get(url);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Map<String, dynamic>> postApi(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(url, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Map<String, dynamic>> imageApi(
    String url,
    FormData formData,
  ) async {
    try {
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {'data': response.data};
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  static Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Server took too long to respond');
      case DioExceptionType.connectionError:
        return Exception('No internet connection');
      default:
        return Exception(e.message ?? 'Network error occurred');
    }
  }
}
