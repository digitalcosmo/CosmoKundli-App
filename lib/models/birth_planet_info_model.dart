class BirthPlanetInfoModel {
  BirthPlanetInfoModel({
    required this.status,
    required this.planets,
  });
  late final bool status;
  late final List<Planets> planets;

  BirthPlanetInfoModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    planets = List.from(json['planets']).map((e)=>Planets.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['planets'] = planets.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Planets {
  Planets({
    required this.planet,
    required this.rashi,
    required this.degree,
    required this.nakshatra,
  });
  late final String planet;
  late final String rashi;
  late final String degree;
  late final String nakshatra;

  Planets.fromJson(Map<String, dynamic> json){
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'];
    nakshatra = json['nakshatra'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['planet'] = planet;
    _data['rashi'] = rashi;
    _data['degree'] = degree;
    _data['nakshatra'] = nakshatra;
    return _data;
  }
}