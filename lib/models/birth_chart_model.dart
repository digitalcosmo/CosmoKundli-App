class BirthChartModel {
  late final bool status;
  late final List<BirthChartPlanet> planets;

  BirthChartModel({required this.status, required this.planets});

  BirthChartModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    planets = List.from(json['planets']).map((e) => BirthChartPlanet.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'planets': planets.map((e) => e.toJson()).toList(),
  };
}

class BirthChartPlanet {
  late final String planet;
  late final String rashi;
  late final String degree;
  late final String color;

  BirthChartPlanet({required this.planet, required this.rashi, required this.degree, required this.color});

  BirthChartPlanet.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() => {'planet': planet, 'rashi': rashi, 'degree': degree, 'color': color};
}
