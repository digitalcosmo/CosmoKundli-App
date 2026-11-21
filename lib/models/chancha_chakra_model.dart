class ChanchaChakra {
  bool? status;
  String? startingRashi;
  List<ChanchaChakraList>? list;

  ChanchaChakra({this.status, this.startingRashi, this.list});

  ChanchaChakra.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    startingRashi = json['starting_rashi'];
    if (json['list'] != null) {
      list = <ChanchaChakraList>[];
      json['list'].forEach((v) { list!.add(ChanchaChakraList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {
    'status': status, 'starting_rashi': startingRashi,
    'list': list?.map((v) => v.toJson()).toList(),
  };
}

class ChanchaChakraList {
  String? rashi;
  List<ChanchaChakraTable>? table;

  ChanchaChakraList({this.rashi, this.table});

  ChanchaChakraList.fromJson(Map<String, dynamic> json) {
    rashi = json['Rashi'];
    if (json['Table'] != null) {
      table = <ChanchaChakraTable>[];
      json['Table'].forEach((v) { table!.add(ChanchaChakraTable.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'Rashi': rashi, 'Table': table?.map((v) => v.toJson()).toList()};
}

class ChanchaChakraTable {
  String? ring;
  List<ChanchaChakraPlanets>? planets;

  ChanchaChakraTable({this.ring, this.planets});

  ChanchaChakraTable.fromJson(Map<String, dynamic> json) {
    ring = json['Ring'];
    if (json['Planets'] != null) {
      planets = <ChanchaChakraPlanets>[];
      json['Planets'].forEach((v) { planets!.add(ChanchaChakraPlanets.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'Ring': ring, 'Planets': planets?.map((v) => v.toJson()).toList()};
}

class ChanchaChakraPlanets {
  String? sa;
  String? ju;
  String? ma;
  String? su;
  String? ve;
  String? me;
  String? mo;
  String? as_;

  ChanchaChakraPlanets({this.sa, this.ju, this.ma, this.su, this.ve, this.me, this.mo, this.as_});

  ChanchaChakraPlanets.fromJson(Map<String, dynamic> json) {
    sa = json['Sa']; ju = json['Ju']; ma = json['Ma']; su = json['Su'];
    ve = json['Ve']; me = json['Me']; mo = json['Mo']; as_ = json['As'];
  }

  Map<String, dynamic> toJson() => {
    'Sa': sa, 'Ju': ju, 'Ma': ma, 'Su': su,
    'Ve': ve, 'Me': me, 'Mo': mo, 'As': as_,
  };
}
