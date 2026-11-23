class GocharTable {
  bool? status;
  List<Planets>? planets;

  GocharTable({this.status, this.planets});

  GocharTable.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['planets'] != null) {
      planets = <Planets>[];
      json['planets'].forEach((v) {
        planets!.add(new Planets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.planets != null) {
      data['planets'] = this.planets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Planets {
  String? planet;
  String? rashi;
  String? degree;
  String? nakshatra;
  String? longitute;

  Planets(
      {this.planet, this.rashi, this.degree, this.nakshatra, this.longitute});

  Planets.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'];
    nakshatra = json['nakshatra'];
    longitute = json['longitute'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planet'] = this.planet;
    data['rashi'] = this.rashi;
    data['degree'] = this.degree;
    data['nakshatra'] = this.nakshatra;
    data['longitute'] = this.longitute;
    return data;
  }
}
