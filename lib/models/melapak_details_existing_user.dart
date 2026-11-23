class MelapakDetailsExistingUser {
  MelapakDetailsExistingUser({
    required this.status,
    required this.VarName,
    required this.VadhuName,
    required this.VarRashi,
    required this.VadhuRashi,
    required this.VarVarn,
    required this.VadhuVarn,
    required this.VarnPoints,
    required this.VarVaishya,
    required this.VadhuVaishya,
    required this.VaishyaPoints,
    required this.VarTara,
    required this.VadhuTara,
    required this.TaraPoints,
    required this.VarYoni,
    required this.VadhuYoni,
    required this.YoniPoints,
    required this.VarRashidhyapati,
    required this.VadhuRashidhyapati,
    required this.RashidhyapatiPoints,
    required this.VarGan,
    required this.VadhuGan,
    required this.GanPoints,
    this.VarBhakoot,
    this.VadhuBhakoot,
    required this.BhakootPoints,
    required this.VarNaadi,
    required this.VadhuNaadi,
    required this.NaadiPoints,
    required this.TotalGunMatch,
    required this.birthChartVadhu,
    required this.navamsaVadhu,
    required this.birthChartVar,
    required this.navamsaVar,
  });
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
  late final Null VarBhakoot;
  late final Null VadhuBhakoot;
  late final String BhakootPoints;
  late final String VarNaadi;
  late final String VadhuNaadi;
  late final String NaadiPoints;
  late final String TotalGunMatch;
  late final List<BirthChartVar> birthChartVar;
  late final List<NavamsaVar> navamsaVar;
  late final List<BirthChartVadhu> birthChartVadhu;
  late final List<NavamsaVadhu> navamsaVadhu;

  MelapakDetailsExistingUser.fromJson(Map<String, dynamic> json){
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
    VarBhakoot = null;
    VadhuBhakoot = null;
    BhakootPoints = json['Bhakoot_Points'];
    VarNaadi = json['Var_Naadi'];
    VadhuNaadi = json['Vadhu_Naadi'];
    NaadiPoints = json['Naadi_Points'];
    TotalGunMatch = json['Total_Gun_Match'];
    birthChartVar = List.from(json['Birth_Chart_Var']).map((e)=>BirthChartVar.fromJson(e)).toList();
    navamsaVar = List.from(json['Navamsa_Var']).map((e)=>NavamsaVar.fromJson(e)).toList();
    birthChartVadhu = List.from(json['Birth_Chart_Vadhu']).map((e)=>BirthChartVadhu.fromJson(e)).toList();
    navamsaVadhu = List.from(json['Navamsa_Vadhu']).map((e)=>NavamsaVadhu.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['Var_Name'] = VarName;
    _data['Vadhu_Name'] = VadhuName;
    _data['Var_Rashi'] = VarRashi;
    _data['Vadhu_Rashi'] = VadhuRashi;
    _data['Var_Varn'] = VarVarn;
    _data['Vadhu_Varn'] = VadhuVarn;
    _data['Varn_Points'] = VarnPoints;
    _data['Var_Vaishya'] = VarVaishya;
    _data['Vadhu_Vaishya'] = VadhuVaishya;
    _data['Vaishya_Points'] = VaishyaPoints;
    _data['Var_Tara'] = VarTara;
    _data['Vadhu_Tara'] = VadhuTara;
    _data['Tara_Points'] = TaraPoints;
    _data['Var_Yoni'] = VarYoni;
    _data['Vadhu_Yoni'] = VadhuYoni;
    _data['Yoni_Points'] = YoniPoints;
    _data['Var_Rashidhyapati'] = VarRashidhyapati;
    _data['Vadhu_Rashidhyapati'] = VadhuRashidhyapati;
    _data['Rashidhyapati_Points'] = RashidhyapatiPoints;
    _data['Var_Gan'] = VarGan;
    _data['Vadhu_Gan'] = VadhuGan;
    _data['Gan_Points'] = GanPoints;
    _data['Var_Bhakoot'] = VarBhakoot;
    _data['Vadhu_Bhakoot'] = VadhuBhakoot;
    _data['Bhakoot_Points'] = BhakootPoints;
    _data['Var_Naadi'] = VarNaadi;
    _data['Vadhu_Naadi'] = VadhuNaadi;
    _data['Naadi_Points'] = NaadiPoints;
    _data['Total_Gun_Match'] = TotalGunMatch;
    _data['Birth_Chart_Var'] = birthChartVar.map((e)=>e.toJson()).toList();
    _data['Navamsa_Var'] = navamsaVar.map((e)=>e.toJson()).toList();
    _data['Birth_Chart_Vadhu'] = birthChartVadhu.map((e)=>e.toJson()).toList();
    _data['Navamsa_Vadhu'] = navamsaVadhu.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class BirthChartVar {
  BirthChartVar({
    required this.planet,
    required this.rashi,
    required this.color,
  });
  late final String planet;
  late final String rashi;
  late final String color;

  BirthChartVar.fromJson(Map<String, dynamic> json){
    planet = json['planet'];
    rashi = json['rashi'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['planet'] = planet;
    _data['rashi'] = rashi;
    _data['color'] = color;
    return _data;
  }
}

class NavamsaVar {
  NavamsaVar({
    required this.planet,
    required this.rashi,
    required this.color,
  });
  late final String planet;
  late final String rashi;
  late final String color;

  NavamsaVar.fromJson(Map<String, dynamic> json){
    planet = json['planet'];
    rashi = json['rashi'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['planet'] = planet;
    _data['rashi'] = rashi;
    _data['color'] = color;
    return _data;
  }
}

class BirthChartVadhu {
  BirthChartVadhu({
    required this.planet,
    required this.rashi,
    required this.color,
  });
  late final String planet;
  late final String rashi;
  late final String color;

  BirthChartVadhu.fromJson(Map<String, dynamic> json){
    planet = json['planet'];
    rashi = json['rashi'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['planet'] = planet;
    _data['rashi'] = rashi;
    _data['color'] = color;
    return _data;
  }
}

class NavamsaVadhu {
  NavamsaVadhu({
    required this.planet,
    required this.rashi,
    required this.color,
  });
  late final String planet;
  late final String rashi;
  late final String color;

  NavamsaVadhu.fromJson(Map<String, dynamic> json){
    planet = json['planet'];
    rashi = json['rashi'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['planet'] = planet;
    _data['rashi'] = rashi;
    _data['color'] = color;
    return _data;
  }
}