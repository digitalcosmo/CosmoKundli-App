import 'package:cosmo_kundli/models/gochar_table_model.dart';
import 'package:cosmo_kundli/models/melapak_details_model.dart';
import 'package:cosmo_kundli/models/melapak_opp_user_list_model.dart';
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/values/urls.dart';

class OtherRepo {
  Future<MelapakOppUserList> fetchMemberList(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.melapakOppUserList, data);
    return MelapakOppUserList.fromJson(response);
  }

  Future<MelapakDetailsExistingUser> matchKundalis(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.melapakDetails, data);
    return MelapakDetailsExistingUser.fromJson(response);
  }

  Future<MelapakDetailsExistingUser> matchKundalisWithNewMember(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.melapakDetails, data);
    return MelapakDetailsExistingUser.fromJson(response);
  }

  Future<GocharTable> fetchGocharTableData(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.gocharAnimated, data);
    return GocharTable.fromJson(response);
  }
}
