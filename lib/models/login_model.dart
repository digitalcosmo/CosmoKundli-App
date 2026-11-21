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
    final data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    data['uID'] = uID;
    data['plan'] = plan;
    data['feature'] = feature ?? [];
    return data;
  }
}
