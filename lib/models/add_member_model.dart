class AddMemberModel {
  bool? status;
  int? mID;
  String? msg;

  AddMemberModel({this.status, this.mID, this.msg});

  AddMemberModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    mID = json['mID'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'mID': mID, 'msg': msg};
}
