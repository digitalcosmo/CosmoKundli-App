class VargKundalisModel {
  bool? status;
  List<Planets>? planets;

  VargKundalisModel({this.status, this.planets});

  VargKundalisModel.fromJson(Map<String, dynamic> json) {
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
  String? color;

  Planets({this.planet, this.rashi, this.color});

  Planets.fromJson(Map<String, dynamic> json) {
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
