class MelapakDetailsExistingUser {
  late final bool status;
  late final String VarName;
  late final String VadhuName;
  late final String VarRashi;
  late final String VadhuRashi;
  late final String VarVarn;
  late final String VadhuVarn;
  late final String VarnPoints;
  late final String VarVaishya;
  late final String VadhuVaishya;
  late final String VaishyaPoints;
  late final String VarTara;
  late final String VadhuTara;
  late final String TaraPoints;
  late final String VarYoni;
  late final String VadhuYoni;
  late final String YoniPoints;
  late final String VarRashidhyapati;
  late final String VadhuRashidhyapati;
  late final String RashidhyapatiPoints;
  late final String VarGan;
  late final String VadhuGan;
  late final String GanPoints;
  late final String BhakootPoints;
  late final String VarNaadi;
  late final String VadhuNaadi;
  late final String NaadiPoints;
  late final String TotalGunMatch;
  late final List<MelapakChartPlanet> birthChartVar;
  late final List<MelapakChartPlanet> navamsaVar;
  late final List<MelapakChartPlanet> birthChartVadhu;
  late final List<MelapakChartPlanet> navamsaVadhu;

  MelapakDetailsExistingUser.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    VarName = json['Var_Name'];
    VadhuName = json['Vadhu_Name'];
    VarRashi = json['Var_Rashi'];
    VadhuRashi = json['Vadhu_Rashi'];
    VarVarn = json['Var_Varn'];
    VadhuVarn = json['Vadhu_Varn'];
    VarnPoints = json['Varn_Points'];
    VarVaishya = json['Var_Vaishya'];
    VadhuVaishya = json['Vadhu_Vaishya'];
    VaishyaPoints = json['Vaishya_Points'];
    VarTara = json['Var_Tara'];
    VadhuTara = json['Vadhu_Tara'];
    TaraPoints = json['Tara_Points'];
    VarYoni = json['Var_Yoni'];
    VadhuYoni = json['Vadhu_Yoni'];
    YoniPoints = json['Yoni_Points'];
    VarRashidhyapati = json['Var_Rashidhyapati'];
    VadhuRashidhyapati = json['Vadhu_Rashidhyapati'];
    RashidhyapatiPoints = json['Rashidhyapati_Points'];
    VarGan = json['Var_Gan'];
    VadhuGan = json['Vadhu_Gan'];
    GanPoints = json['Gan_Points'];
    BhakootPoints = json['Bhakoot_Points'];
    VarNaadi = json['Var_Naadi'];
    VadhuNaadi = json['Vadhu_Naadi'];
    NaadiPoints = json['Naadi_Points'];
    TotalGunMatch = json['Total_Gun_Match'];
    birthChartVar = List.from(json['Birth_Chart_Var']).map((e) => MelapakChartPlanet.fromJson(e)).toList();
    navamsaVar = List.from(json['Navamsa_Var']).map((e) => MelapakChartPlanet.fromJson(e)).toList();
    birthChartVadhu = List.from(json['Birth_Chart_Vadhu']).map((e) => MelapakChartPlanet.fromJson(e)).toList();
    navamsaVadhu = List.from(json['Navamsa_Vadhu']).map((e) => MelapakChartPlanet.fromJson(e)).toList();
  }
}

class MelapakChartPlanet {
  late final String planet;
  late final String rashi;
  late final String color;

  MelapakChartPlanet.fromJson(Map<String, dynamic> json) {
    planet = json['planet'];
    rashi = json['rashi'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() => {'planet': planet, 'rashi': rashi, 'color': color};
}
