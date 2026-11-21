class SaniPanotiModel {
  bool? status;
  List<SaniPanotiList>? list;

  SaniPanotiModel({this.status, this.list});

  SaniPanotiModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <SaniPanotiList>[];
      json['list'].forEach((v) { list!.add(SaniPanotiList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class SaniPanotiList {
  String? panoti;
  String? rashi;
  String? startDate;
  String? endDate;
  String? duration;

  SaniPanotiList({this.panoti, this.rashi, this.startDate, this.endDate, this.duration});

  SaniPanotiList.fromJson(Map<String, dynamic> json) {
    panoti = json['Panoti'];
    rashi = json['Rashi'];
    startDate = json['Start Date'];
    endDate = json['End Date'];
    duration = json['Duration'];
  }

  Map<String, dynamic> toJson() => {
    'Panoti': panoti, 'Rashi': rashi, 'Start Date': startDate,
    'End Date': endDate, 'Duration': duration,
  };
}
