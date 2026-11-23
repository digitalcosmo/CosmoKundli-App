class CosmoPowerModel {
  bool? status;
  List<CosmoPowerList>? list;

  CosmoPowerModel({this.status, this.list});

  CosmoPowerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <CosmoPowerList>[];
      json['list'].forEach((v) {
        list!.add(new CosmoPowerList.fromJson(v));
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

class CosmoPowerList {
  String? date;
  double? value;

  CosmoPowerList({this.date, this.value});

  CosmoPowerList.fromJson(Map<String, dynamic> json) {
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
