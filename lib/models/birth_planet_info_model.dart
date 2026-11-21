class BirthPlanetInfoModel {
  late final bool status;
  late final List<BirthPlanetInfo> planets;

  BirthPlanetInfoModel({required this.status, required this.planets});

  BirthPlanetInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    planets = List.from(json['planets']).map((e) => BirthPlanetInfo.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'planets': planets.map((e) => e.toJson()).toList(),
  };
}

class BirthPlanetInfo {
  late final String planet;
  late final String rashi;
  late final String degree;
  late final String nakshatra;

  BirthPlanetInfo({required this.planet, required this.rashi, required this.degree, required this.nakshatra});

  BirthPlanetInfo.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'];
    nakshatra = json['nakshatra'];
  }

  Map<String, dynamic> toJson() => {'planet': planet, 'rashi': rashi, 'degree': degree, 'nakshatra': nakshatra};
}
