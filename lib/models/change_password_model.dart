class ChangePassword {
  bool? status;
  String? message;

  ChangePassword({this.status, this.message});

  ChangePassword.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'Message': message};
}
