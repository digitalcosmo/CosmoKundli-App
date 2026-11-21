class PeriodicMonthlyReportModel {
  bool? status;
  List<PeriodicMonthlyReportList>? list;

  PeriodicMonthlyReportModel({this.status, this.list});

  PeriodicMonthlyReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <PeriodicMonthlyReportList>[];
      json['list'].forEach((v) { list!.add(PeriodicMonthlyReportList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class PeriodicMonthlyReportList {
  String? title;
  double? value;

  PeriodicMonthlyReportList({this.title, this.value});

  PeriodicMonthlyReportList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = double.parse(json['value'].toDouble().toStringAsFixed(2));
  }

  Map<String, dynamic> toJson() => {'title': title, 'value': value};
}
