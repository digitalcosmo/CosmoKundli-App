class ChangePassword {
  bool? status;
  String? message;

  ChangePassword({this.status, this.message});

  ChangePassword.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}
