import 'package:cosmo_kundli/models/add_member_model.dart';
import 'package:cosmo_kundli/models/delete_member_model.dart';
import 'package:cosmo_kundli/models/member_list_model.dart';
import 'package:cosmo_kundli/models/member_detail_model.dart';
import 'package:cosmo_kundli/network/network_api_services.dart';
import 'package:cosmo_kundli/values/urls.dart';

class MemberRepo {
  Future<AddMemberModel> addMember(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.memberAdd, data);
    return AddMemberModel.fromJson(response);
  }

  Future<AddMemberModel> updateMember(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.memberUpdate, data);
    return AddMemberModel.fromJson(response);
  }

  Future<DeleteMemberModel> deleteMember(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.memberDelete, data);
    return DeleteMemberModel.fromJson(response);
  }

  Future<MemberListModel> fetchMemberList(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.memberList, data);
    return MemberListModel.fromJson(response);
  }

  Future<MemberDetails> fetchMemberDetails(Map<String, dynamic> data) async {
    final response = await NetworkApiServices.postApi(Urls.memberDetails, data);
    return MemberDetails.fromJson(response);
  }
}
