
import 'package:cosmo_kundali/models/melapak_opp_user_list_model.dart';

import '../models/add_member_model.dart';
import '../models/gochar_table_model.dart';
import '../models/melapak_details_existing_user.dart';
import '../network/network_api_services.dart';
import '../values/urls.dart';

class OtherRepo
{
  final NetworkApiServices networkApiServices = NetworkApiServices();

  Future<MelapakOppUserList> fetchMemberList(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Melapak_Opp_User_List);
    return MelapakOppUserList.fromJson(response);
  }

  Future<MelapakDetailsExistingUser> matchKundalis(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Melapak_Details_Existing_User);
    return MelapakDetailsExistingUser.fromJson(response);
  }

  Future<MelapakDetailsExistingUser> matchKundalisWithNewMember(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.Melapak_Details_New_User);
    return MelapakDetailsExistingUser.fromJson(response);
  }

  Future<GocharTable> fetchGocharTableData(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.GocharAnimated);
    return GocharTable .fromJson(response);
  }




}