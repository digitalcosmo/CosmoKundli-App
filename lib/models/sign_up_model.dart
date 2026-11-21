class SignUpModel {
  bool? status;
  String? msg;

  SignUpModel({this.status, this.msg});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'msg': msg};
}
