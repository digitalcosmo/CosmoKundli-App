class DeleteMemberModel {
  bool? status;
  String? msg;

  DeleteMemberModel({this.status, this.msg});

  DeleteMemberModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'msg': msg};
}
