class TaraChakra {
  bool? status;
  List<TaraChakraList>? list;

  TaraChakra({this.status, this.list});

  TaraChakra.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <TaraChakraList>[];
      json['list'].forEach((v) { list!.add(TaraChakraList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'list': list?.map((v) => v.toJson()).toList()};
}

class TaraChakraList {
  String? tara;
  String? nakshatra;

  TaraChakraList({this.tara, this.nakshatra});

  TaraChakraList.fromJson(Map<String, dynamic> json) {
    tara = json['Tara'];
    nakshatra = json['Nakshatra'];
  }

  Map<String, dynamic> toJson() => {'Tara': tara, 'Nakshatra': nakshatra};
}
