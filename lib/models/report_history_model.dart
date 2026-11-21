class ReportHistoryModel {
  bool? status;
  List<ReportItem>? list;

  ReportHistoryModel({this.status, this.list});

  ReportHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <ReportItem>[];
      json['list'].forEach((v) { list!.add(ReportItem.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class ReportItem {
  String? date;
  String? type;
  String? name;
  String? month;
  String? status;
  String? downloadLink;

  ReportItem({this.date, this.type, this.name, this.month, this.status, this.downloadLink});

  ReportItem.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    type = json['Type'];
    name = json['Name'];
    month = json['Month'];
    status = json['Status'];
    downloadLink = json['Download_Link'];
  }

  Map<String, dynamic> toJson() => {
    'Date': date, 'Type': type, 'Name': name,
    'Month': month, 'Status': status, 'Download_Link': downloadLink,
  };
}
