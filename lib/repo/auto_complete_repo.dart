import 'package:cosmo_kundali/network/network_api_services.dart';
import 'package:cosmo_kundali/values/urls.dart';
import 'package:dio/dio.dart';

import '../models/google_place_model.dart';

class GooglePlaceRepo {
  final NetworkApiServices _networkApiServices = NetworkApiServices();

  Future<GooglePlaceModel> fetchPlaces(
      {required Map<String, dynamic> qp}) async {
    Map<String,dynamic> response = await _networkApiServices
        .getApi(AppUrls.googlePlaceAutoCompleteApi, qp: qp);
    return GooglePlaceModel.fromJson(response);
  }
}
