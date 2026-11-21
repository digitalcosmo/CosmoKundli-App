class ResetPassword {
  bool? status;
  String? msg;

  ResetPassword({this.status, this.msg});

  ResetPassword.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'msg': msg};
}
