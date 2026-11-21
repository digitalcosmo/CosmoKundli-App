class StarPowerReport {
  bool? status;
  List<StarPowerReportList>? list;

  StarPowerReport({this.status, this.list});

  StarPowerReport.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <StarPowerReportList>[];
      json['list'].forEach((v) { list!.add(StarPowerReportList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class StarPowerReportList {
  double? moday;
  double? tuesday;
  double? wednesday;
  double? thursday;
  double? friday;
  double? saturday;
  double? sunday;

  StarPowerReportList({this.moday, this.tuesday, this.wednesday, this.thursday, this.friday, this.saturday, this.sunday});

  StarPowerReportList.fromJson(Map<String, dynamic> json) {
    moday = json['Moday']?.toDouble();
    tuesday = json['Tuesday']?.toDouble();
    wednesday = json['Wednesday']?.toDouble();
    thursday = json['Thursday']?.toDouble();
    friday = json['Friday']?.toDouble();
    saturday = json['Saturday']?.toDouble();
    sunday = json['Sunday']?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'Moday': moday, 'Tuesday': tuesday, 'Wednesday': wednesday,
    'Thursday': thursday, 'Friday': friday, 'Saturday': saturday, 'Sunday': sunday,
  };
}
