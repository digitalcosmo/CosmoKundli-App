class ImageUpdate {
  bool? status;
  String? message;

  ImageUpdate({this.status, this.message});

  ImageUpdate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'Message': message};
}
