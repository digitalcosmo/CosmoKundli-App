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
      json['list'].forEach((v) {
        list!.add(new ChanchaChakraList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['starting_rashi'] = this.startingRashi;
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChanchaChakraList {
  String? rashi;
  List<Table>? table;

  ChanchaChakraList({this.rashi, this.table});

  ChanchaChakraList.fromJson(Map<String, dynamic> json) {
    rashi = json['Rashi'];
    if (json['Table'] != null) {
      table = <Table>[];
      json['Table'].forEach((v) {
        table!.add(new Table.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Rashi'] = this.rashi;
    if (this.table != null) {
      data['Table'] = this.table!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Table {
  String? ring;
  List<Planets>? planets;

  Table({this.ring, this.planets});

  Table.fromJson(Map<String, dynamic> json) {
    ring = json['Ring'];
    if (json['Planets'] != null) {
      planets = <Planets>[];
      json['Planets'].forEach((v) {
        planets!.add(new Planets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Ring'] = this.ring;
    if (this.planets != null) {
      data['Planets'] = this.planets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Planets {
  String? sa;
  String? ju;
  String? ma;
  String? su;
  String? ve;
  String? me;
  String? mo;
  String? as;

  Planets(
      {this.sa, this.ju, this.ma, this.su, this.ve, this.me, this.mo, this.as});

  Planets.fromJson(Map<String, dynamic> json) {
    sa = json['Sa'];
    ju = json['Ju'];
    ma = json['Ma'];
    su = json['Su'];
    ve = json['Ve'];
    me = json['Me'];
    mo = json['Mo'];
    as = json['As'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Sa'] = this.sa;
    data['Ju'] = this.ju;
    data['Ma'] = this.ma;
    data['Su'] = this.su;
    data['Ve'] = this.ve;
    data['Me'] = this.me;
    data['Mo'] = this.mo;
    data['As'] = this.as;
    return data;
  }
}
