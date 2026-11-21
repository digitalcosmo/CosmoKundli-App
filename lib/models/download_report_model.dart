class DownloadReport {
  bool? status;
  String? msg;

  DownloadReport({this.status, this.msg});

  DownloadReport.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() => {'status': status, 'msg': msg};
}
