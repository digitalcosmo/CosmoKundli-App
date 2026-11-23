class LoginModel {
  bool? status;
  String? msg;
  String? uID;
  String? plan;
  List<String>? feature = [];

  LoginModel({this.status, this.msg, this.uID, this.plan, this.feature});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    uID = json['uID'];
    plan = json['plan'];
    feature = (json['feature'] as List?)?.cast<String>() ?? [];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    data['uID'] = this.uID;
    data['plan'] = this.plan;
    data['feature'] = feature ?? [].cast<String>();
    return data;
  }
}
