class DashaModel {
  bool? status;
  String? dashaBalanceGrah;
  String? dashaBalanceColor;
  String? dashaBalance;
  String? subGrah1;
  String? subGrahColor1;
  String? subGrah2;
  String? subGrahColor2;
  String? subGrah3;
  String? subGrahColor3;
  List<DashaList>? list;

  DashaModel({this.status, this.dashaBalanceGrah, this.dashaBalanceColor,
    this.dashaBalance, this.subGrah1, this.subGrahColor1, this.subGrah2,
    this.subGrahColor2, this.subGrah3, this.subGrahColor3, this.list});

  DashaModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    dashaBalanceGrah = json['dasha_balance_grah'];
    dashaBalanceColor = json['dasha_balance_color'];
    dashaBalance = json['dasha_balance'];
    subGrah1 = json['sub_grah_1'];
    subGrahColor1 = json['sub_grah_color_1'];
    subGrah2 = json['sub_grah_2'];
    subGrahColor2 = json['sub_grah_color_2'];
    subGrah3 = json['sub_grah_3'];
    subGrahColor3 = json['sub_grah_color_3'];
    if (json['list'] != null) {
      list = <DashaList>[];
      json['list'].forEach((v) { list!.add(DashaList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['dasha_balance_grah'] = dashaBalanceGrah;
    data['dasha_balance_color'] = dashaBalanceColor;
    data['dasha_balance'] = dashaBalance;
    data['sub_grah_1'] = subGrah1;
    data['sub_grah_color_1'] = subGrahColor1;
    data['sub_grah_2'] = subGrah2;
    data['sub_grah_color_2'] = subGrahColor2;
    data['sub_grah_3'] = subGrah3;
    data['sub_grah_color_3'] = subGrahColor3;
    if (list != null) data['list'] = list!.map((v) => v.toJson()).toList();
    return data;
  }
}

class DashaList {
  String? title;
  String? color;
  List<GrahList>? list;

  DashaList({this.title, this.color, this.list});

  DashaList.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    color = json['Color'];
    if (json['list'] != null) {
      list = <GrahList>[];
      json['list'].forEach((v) { list!.add(GrahList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Title'] = title;
    data['Color'] = color;
    if (list != null) data['list'] = list!.map((v) => v.toJson()).toList();
    return data;
  }
}

class GrahList {
  String? grah;
  String? color;
  String? start;
  String? end;
  DashaRow? row1;
  DashaRow? row2;
  DashaRow? row3;
  DashaRow? row4;
  DashaRow? row5;
  DashaRow? row6;
  DashaRow? row7;
  DashaRow? row8;
  DashaRow? row9;

  GrahList({this.grah, this.color, this.start, this.end,
    this.row1, this.row2, this.row3, this.row4, this.row5,
    this.row6, this.row7, this.row8, this.row9});

  GrahList.fromJson(Map<String, dynamic> json) {
    grah = json['Grah'];
    color = json['Color'];
    start = json['Start'];
    end = json['End'];
    row1 = json['Row 1'] != null ? DashaRow.fromJson(json['Row 1']) : null;
    row2 = json['Row 2'] != null ? DashaRow.fromJson(json['Row 2']) : null;
    row3 = json['Row 3'] != null ? DashaRow.fromJson(json['Row 3']) : null;
    row4 = json['Row 4'] != null ? DashaRow.fromJson(json['Row 4']) : null;
    row5 = json['Row 5'] != null ? DashaRow.fromJson(json['Row 5']) : null;
    row6 = json['Row 6'] != null ? DashaRow.fromJson(json['Row 6']) : null;
    row7 = json['Row 7'] != null ? DashaRow.fromJson(json['Row 7']) : null;
    row8 = json['Row 8'] != null ? DashaRow.fromJson(json['Row 8']) : null;
    row9 = json['Row 9'] != null ? DashaRow.fromJson(json['Row 9']) : null;
  }

  List<DashaRow?> get rows => [row1, row2, row3, row4, row5, row6, row7, row8, row9];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Grah'] = grah;
    data['Color'] = color;
    data['Start'] = start;
    data['End'] = end;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i] != null) data['Row ${i + 1}'] = rows[i]!.toJson();
    }
    return data;
  }
}

class DashaRow {
  String? grah;
  String? color;
  String? start;
  String? end;

  DashaRow({this.grah, this.color, this.start, this.end});

  DashaRow.fromJson(Map<String, dynamic> json) {
    grah = json['Grah'];
    color = json['Color'];
    start = json['Start'];
    end = json['End'];
  }

  Map<String, dynamic> toJson() => {'Grah': grah, 'Color': color, 'Start': start, 'End': end};
}
