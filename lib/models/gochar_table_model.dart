class GocharTable {
  bool? status;
  List<GocharPlanet>? planets;

  GocharTable({this.status, this.planets});

  GocharTable.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['planets'] != null) {
      planets = <GocharPlanet>[];
      json['planets'].forEach((v) { planets!.add(GocharPlanet.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'planets': planets?.map((v) => v.toJson()).toList()};
}

class GocharPlanet {
  String? planet;
  String? rashi;
  String? degree;
  String? nakshatra;
  String? longitute;

  GocharPlanet({this.planet, this.rashi, this.degree, this.nakshatra, this.longitute});

  GocharPlanet.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'];
    nakshatra = json['nakshatra'];
    longitute = json['longitute'];
  }

  Map<String, dynamic> toJson() => {
    'planet': planet, 'rashi': rashi, 'degree': degree,
    'nakshatra': nakshatra, 'longitute': longitute,
  };
}
