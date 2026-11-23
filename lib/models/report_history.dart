class ReportHistoryModel {
  bool? status;
  List<ReportList>? list;

  ReportHistoryModel({this.status, this.list});

  ReportHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <ReportList>[];
      json['list'].forEach((v) {
        list!.add(new ReportList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReportList {
  String? date;
  String? type;
  String? name;
  String? month;
  String? status;
  String? downloadLink;

  ReportList(
      {this.date,
        this.type,
        this.name,
        this.month,
        this.status,
        this.downloadLink});

  ReportList.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    type = json['Type'];
    name = json['Name'];
    month = json['Month'];
    status = json['Status'];
    downloadLink = json['Download_Link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['Type'] = this.type;
    data['Name'] = this.name;
    data['Month'] = this.month;
    data['Status'] = this.status;
    data['Download_Link'] = this.downloadLink;
    return data;
  }
}
