class ShabdalGraphModel {
  bool? status;
  List<ShabdalList>? list;

  ShabdalGraphModel({this.status, this.list});

  ShabdalGraphModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <ShabdalList>[];
      json['list'].forEach((v) {
        list!.add(new ShabdalList.fromJson(v));
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

class ShabdalList {
  String? title;
  double? value;

  ShabdalList({this.title, this.value});

  ShabdalList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    return data;
  }
}
