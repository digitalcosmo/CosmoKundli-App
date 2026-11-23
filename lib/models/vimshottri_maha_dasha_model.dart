class VimshottriMahaDashaModel {
  bool? status;
  List<VimshottriMahaDashaList>? list;

  VimshottriMahaDashaModel({this.status, this.list});

  VimshottriMahaDashaModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <VimshottriMahaDashaList>[];
      json['list'].forEach((v) {
        list!.add(new VimshottriMahaDashaList.fromJson(v));
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

class VimshottriMahaDashaList {
  String? planet;
  String? startDate;
  String? endDate;

  VimshottriMahaDashaList({this.planet, this.startDate, this.endDate});

  VimshottriMahaDashaList.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planet'] = this.planet;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    return data;
  }
}
