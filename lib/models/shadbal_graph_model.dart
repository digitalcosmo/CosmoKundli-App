class ShabdalGraphModel {
  bool? status;
  List<ShabdalList>? list;

  ShabdalGraphModel({this.status, this.list});

  ShabdalGraphModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <ShabdalList>[];
      json['list'].forEach((v) { list!.add(ShabdalList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'list': list?.map((v) => v.toJson()).toList(),
  };
}

class ShabdalList {
  String? title;
  double? value;

  ShabdalList({this.title, this.value});

  ShabdalList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value']?.toDouble();
  }

  Map<String, dynamic> toJson() => {'title': title, 'value': value};
}
