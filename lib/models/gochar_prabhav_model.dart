class GocharPrabhavModel {
  bool? status;
  List<GocharPrabhavList>? list;

  GocharPrabhavModel({this.status, this.list});

  GocharPrabhavModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <GocharPrabhavList>[];
      json['list'].forEach((v) { list!.add(GocharPrabhavList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class GocharPrabhavList {
  String? title;
  double? value;

  GocharPrabhavList({this.title, this.value});

  GocharPrabhavList.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    value = json['Value']?.toDouble();
  }

  Map<String, dynamic> toJson() => {'Title': title, 'Value': value};
}
