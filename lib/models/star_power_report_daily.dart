class StarPowerReportDaily {
  bool? status;
  List<StarPowerReportDailyList>? list;

  StarPowerReportDaily({this.status, this.list});

  StarPowerReportDaily.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <StarPowerReportDailyList>[];
      json['list'].forEach((v) {
        list!.add(new StarPowerReportDailyList.fromJson(v));
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

class StarPowerReportDailyList {
  String? date;
  double? value;

  StarPowerReportDailyList({this.date, this.value});

  StarPowerReportDailyList.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    value = json['Value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['Value'] = this.value;
    return data;
  }
}
