class FiveFoldRelationshipModel {
  final String sun;
  final String moon;
  final String mars;
  final String mercury;
  final String jupiter;
  final String venus;
  final String saturn;
  final String rahu;
  final String ketu;

  FiveFoldRelationshipModel({
    required this.sun, required this.moon, required this.mars,
    required this.mercury, required this.jupiter, required this.venus,
    required this.saturn, required this.rahu, required this.ketu,
  });

  factory FiveFoldRelationshipModel.fromJson(Map<String, dynamic> json) {
    return FiveFoldRelationshipModel(
      sun: json['Sun'], moon: json['Moon'], mars: json['Mars'],
      mercury: json['Mercury'], jupiter: json['Jupiter'], venus: json['Venus'],
      saturn: json['Saturn'], rahu: json['Rahu'], ketu: json['Ketu'],
    );
  }
}

class PlanetInfo {
  final String planet;
  final FiveFoldRelationshipModel planets;

  PlanetInfo({required this.planet, required this.planets});

  factory PlanetInfo.fromJson(Map<String, dynamic> json) {
    return PlanetInfo(
      planet: json['planet'],
      planets: FiveFoldRelationshipModel.fromJson(json['planets']),
    );
  }
}

class PlanetData {
  final bool status;
  final List<PlanetInfo> list;

  PlanetData({required this.status, required this.list});

  factory PlanetData.fromJson(Map<String, dynamic> json) {
    return PlanetData(
      status: json['status'],
      list: (json['list'] as List).map((i) => PlanetInfo.fromJson(i)).toList(),
    );
  }
}
