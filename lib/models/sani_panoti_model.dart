class SaniPanotiModel {
  bool? status;
  List<SaniPanotiList>? list;

  SaniPanotiModel({this.status, this.list});

  SaniPanotiModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <SaniPanotiList>[];
      json['list'].forEach((v) {
        list!.add(new SaniPanotiList.fromJson(v));
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Panoti'] = this.panoti;
    data['Rashi'] = this.rashi;
    data['Start Date'] = this.startDate;
    data['End Date'] = this.endDate;
    data['Duration'] = this.duration;
    return data;
  }
}
