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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['mID'] = mID;
    data['msg'] = msg;
    return data;
  }
}