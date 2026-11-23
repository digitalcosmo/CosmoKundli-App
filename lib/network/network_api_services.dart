import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../values/urls.dart';
import 'app_exceptions.dart';
import 'base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  Dio dio = Dio(BaseOptions(baseUrl: AppUrls.baseUrl));

  @override
  Future getApi(String url, {Map<String, dynamic>? qp}) async {
    try {
      Response response = await dio
          .get(url, queryParameters: qp)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
            requestOptions: RequestOptions(path: url),
            response: response,
            type: DioExceptionType.connectionError);
      }
    } on DioException catch (e) {
      debugPrint("Error In Dio ${e.toString()} \n URL $url");
      throwException(e);
    } on ConnectionTimeoutException {
      throw ConnectionTimeoutException("");
    }
  }

  @override
  Future postApi(Map<String, dynamic> data, String url) async {
    try {
      Response response =
          await dio.post(url, data: data).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
            requestOptions: RequestOptions(path: url),
            response: response,
            type: DioExceptionType.connectionError);
      }
    } on DioException catch (e,s) {
      debugPrint("Error In Dio ${e.toString()} \nError URL $url");
      debugPrint(s.toString());
      throwException(e);
    }
  }

  @override
  Future imageApi(FormData data, String url) async {
    try {
      Response response =
          await dio.post(url, data: data).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
            requestOptions: RequestOptions(path: url),
            response: response,
            type: DioExceptionType.connectionError);
      }
    } on DioException catch (e) {
      debugPrint("Error In Dio ${e.toString()}");
      throwException(e);
    }
  }

  dynamic throwException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.badResponse:
        throw FetchDataException('Error ');
      case DioExceptionType.connectionTimeout:
        throw ConnectionExceptions('Error ');
      case DioExceptionType.sendTimeout:
        throw FetchDataException('Error ');
      case DioExceptionType.receiveTimeout:
        throw ConnectionTimeoutException('Error ');
      case DioExceptionType.badCertificate:
        throw FetchDataException('Error ');
      case DioExceptionType.cancel:
        throw FetchDataException('Error ');
      case DioExceptionType.connectionError:
        throw ServerException('Error ');
      case DioExceptionType.unknown:
        throw FetchDataException('Error ');
    }
  }
}
