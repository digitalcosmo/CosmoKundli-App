class VimshottriMahaDashaModel {
  bool? status;
  List<VimshottriMahaDashaList>? list;

  VimshottriMahaDashaModel({this.status, this.list});

  VimshottriMahaDashaModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <VimshottriMahaDashaList>[];
      json['list'].forEach((v) { list!.add(VimshottriMahaDashaList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'list': list?.map((v) => v.toJson()).toList(),
  };
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

  Map<String, dynamic> toJson() => {'planet': planet, 'start_date': startDate, 'end_date': endDate};
}
