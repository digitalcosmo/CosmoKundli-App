class NavmanshModel {
  bool? status;
  List<NavmanshPlanets>? planets;

  NavmanshModel({this.status, this.planets});

  NavmanshModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['planets'] != null) {
      planets = <NavmanshPlanets>[];
      json['planets'].forEach((v) {
        planets!.add(new NavmanshPlanets.fromJson(v));
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

class NavmanshPlanets {
  String? planet;
  String? rashi;
  String? color;

  NavmanshPlanets({this.planet, this.rashi, this.color});

  NavmanshPlanets.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planet'] = this.planet;
    data['rashi'] = this.rashi;
    data['color'] = this.color;
    return data;
  }
}
