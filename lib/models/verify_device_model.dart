class VerifyDeviceModel {
  bool? status;
  String? msg;

  VerifyDeviceModel({this.status, this.msg});

  VerifyDeviceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'msg': msg};
}
