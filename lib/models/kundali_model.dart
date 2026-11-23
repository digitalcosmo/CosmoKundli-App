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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planet'] = this.planet;
    data['rashi'] = this.rashi;
    data['degree'] = this.degree;
    data['color'] = this.color;
    return data;
  }
}
