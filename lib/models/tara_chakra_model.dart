class TaraChakra {
  bool? status;
  List<TaraChakraList>? list;

  TaraChakra({this.status, this.list});

  TaraChakra.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <TaraChakraList>[];
      json['list'].forEach((v) {
        list!.add(new TaraChakraList.fromJson(v));
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

class TaraChakraList {
  String? tara;
  String? nakshatra;

  TaraChakraList({this.tara, this.nakshatra});

  TaraChakraList.fromJson(Map<String, dynamic> json) {
    tara = json['Tara'];
    nakshatra = json['Nakshatra'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Tara'] = this.tara;
    data['Nakshatra'] = this.nakshatra;
    return data;
  }
}
