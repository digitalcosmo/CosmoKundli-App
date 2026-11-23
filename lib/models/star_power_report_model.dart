class StarPowerReport {
  bool? status;
  List<StarPowerReportList>? list;

  StarPowerReport({this.status, this.list});

  StarPowerReport.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <StarPowerReportList>[];
      json['list'].forEach((v) {
        list!.add(new StarPowerReportList.fromJson(v));
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

class StarPowerReportList {
  double? moday;
  double? tuesday;
  double? wednesday;
  double? thursday;
  double? friday;
  double? saturday;
  double? sunday;

  StarPowerReportList(
      {this.moday,
        this.tuesday,
        this.wednesday,
        this.thursday,
        this.friday,
        this.saturday,
        this.sunday});

  StarPowerReportList.fromJson(Map<String, dynamic> json) {
    moday = json['Moday'];
    tuesday = json['Tuesday'];
    wednesday = json['Wednesday'];
    thursday = json['Thursday'];
    friday = json['Friday'];
    saturday = json['Saturday'];
    sunday = json['Sunday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Moday'] = this.moday;
    data['Tuesday'] = this.tuesday;
    data['Wednesday'] = this.wednesday;
    data['Thursday'] = this.thursday;
    data['Friday'] = this.friday;
    data['Saturday'] = this.saturday;
    data['Sunday'] = this.sunday;
    return data;
  }
}
