class ForgotPassword {
  bool? status;
  String? email;
  String? msg;

  ForgotPassword({this.status, this.email, this.msg});

  ForgotPassword.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    email = json['email'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'email': email, 'msg': msg};
}
