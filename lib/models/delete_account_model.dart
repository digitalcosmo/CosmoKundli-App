class DeleteAccountModel {
  bool? status;
  String? message;

  DeleteAccountModel({this.status, this.message});

  DeleteAccountModel.fromJson(Map<String, dynamic> json) {
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
