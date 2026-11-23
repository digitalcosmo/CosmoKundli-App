class GocharPrabhavModel {
  bool? status;
  List<GocharPrabhavList>? list;

  GocharPrabhavModel({this.status, this.list});

  GocharPrabhavModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <GocharPrabhavList>[];
      json['list'].forEach((v) {
        list!.add(new GocharPrabhavList.fromJson(v));
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

class GocharPrabhavList {
  String? title;
  double? value;

  GocharPrabhavList({this.title, this.value});

  GocharPrabhavList.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    value = json['Value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    data['Value'] = this.value;
    return data;
  }
}
