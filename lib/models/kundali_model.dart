class KundaliModel {
  String? planet;
  String? rashi;
  String? degree;
  String? color;

  KundaliModel({this.planet, this.rashi, this.degree, this.color});

  KundaliModel.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    degree = json['degree'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() => {'planet': planet, 'rashi': rashi, 'degree': degree, 'color': color};
}
