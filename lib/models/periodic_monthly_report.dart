class PeriodicMonthlyReportModel {
  bool? status;
  List<PeriodicMonthlyReportList>? list;

  PeriodicMonthlyReportModel({this.status, this.list});

  PeriodicMonthlyReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <PeriodicMonthlyReportList>[];
      json['list'].forEach((v) {
        list!.add(new PeriodicMonthlyReportList.fromJson(v));
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

class PeriodicMonthlyReportList {
  String? title;
  double? value;

  PeriodicMonthlyReportList({this.title, this.value});

  PeriodicMonthlyReportList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = double.parse(json['value'].toDouble().toStringAsFixed(2) .toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    return data;
  }
}
