class StarPowerReportDaily {
  bool? status;
  List<StarPowerReportDailyList>? list;

  StarPowerReportDaily({this.status, this.list});

  StarPowerReportDaily.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <StarPowerReportDailyList>[];
      json['list'].forEach((v) { list!.add(StarPowerReportDailyList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class StarPowerReportDailyList {
  String? date;
  double? value;

  StarPowerReportDailyList({this.date, this.value});

  StarPowerReportDailyList.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    value = json['Value']?.toDouble();
  }

  Map<String, dynamic> toJson() => {'Date': date, 'Value': value};
}
