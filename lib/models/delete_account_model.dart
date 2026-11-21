class DeleteAccountModel {
  bool? status;
  String? message;

  DeleteAccountModel({this.status, this.message});

  DeleteAccountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'Message': message};
}
