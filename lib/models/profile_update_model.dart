class ProfileUpdate {
  bool? status;
  String? message;

  ProfileUpdate({this.status, this.message});

  ProfileUpdate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'Message': message};
}
