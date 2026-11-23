import 'package:cosmo_kundali/models/delete_member.dart';
import 'package:cosmo_kundali/models/member_details.dart';
import 'package:cosmo_kundali/models/shadbal_graph.dart';
import 'package:flutter/material.dart';

import '../models/add_member_model.dart';
import '../models/member_list_model.dart';
import '../network/network_api_services.dart';
import '../values/urls.dart';

class AddMemberRepo
{
  final NetworkApiServices networkApiServices = NetworkApiServices();

  Future<AddMemberModel> addMember(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.memberAdd);
    debugPrint('Add Mem Response ${response}');

    return AddMemberModel .fromJson(response);
  }

  Future<AddMemberModel> updateMember(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.MemberUpdate);
    debugPrint('Add Mem Response ${response}');

    return AddMemberModel .fromJson(response);
  }

  Future<DeleteMemberModel> deleteMember(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.memberDelete);
    return DeleteMemberModel.fromJson(response);
  }

  Future<MemberListModel> fetchMemberList(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.memberList);
    return MemberListModel.fromJson(response);
  }

  Future<MemberDetails> fetchMemberDetails(Map<String, dynamic> data) async {
    Map<String, dynamic> response =
    await networkApiServices.postApi(data, AppUrls.memberDetails);
    return MemberDetails.fromJson(response);
  }


}