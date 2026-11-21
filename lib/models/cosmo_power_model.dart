class CosmoPowerModel {
  bool? status;
  List<CosmoPowerList>? list;

  CosmoPowerModel({this.status, this.list});

  CosmoPowerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <CosmoPowerList>[];
      json['list'].forEach((v) { list!.add(CosmoPowerList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class CosmoPowerList {
  String? date;
  double? value;

  CosmoPowerList({this.date, this.value});

  CosmoPowerList.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    value = json['Value']?.toDouble();
  }

  Map<String, dynamic> toJson() => {'Date': date, 'Value': value};
}
