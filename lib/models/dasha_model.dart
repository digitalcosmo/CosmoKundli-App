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

  DashaModel(
      {this.status,
        this.dashaBalanceGrah,
        this.dashaBalanceColor,
        this.dashaBalance,
        this.subGrah1,
        this.subGrahColor1,
        this.subGrah2,
        this.subGrahColor2,
        this.subGrah3,
        this.subGrahColor3,
        this.list});

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
      json['list'].forEach((v) {
        list!.add(new DashaList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['dasha_balance_grah'] = this.dashaBalanceGrah;
    data['dasha_balance_color'] = this.dashaBalanceColor;
    data['dasha_balance'] = this.dashaBalance;
    data['sub_grah_1'] = this.subGrah1;
    data['sub_grah_color_1'] = this.subGrahColor1;
    data['sub_grah_2'] = this.subGrah2;
    data['sub_grah_color_2'] = this.subGrahColor2;
    data['sub_grah_3'] = this.subGrah3;
    data['sub_grah_color_3'] = this.subGrahColor3;
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
    }
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
      json['list'].forEach((v) {
        list!.add(new GrahList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    data['Color'] = this.color;
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GrahList {
  String? grah;
  String? color;
  String? start;
  String? end;
  Row1? row1;
  Row1? row2;
  Row1? row3;
  Row1? row4;
  Row1? row5;
  Row1? row6;
  Row1? row7;
  Row1? row8;
  Row1? row9;

  GrahList(
      {this.grah,
        this.color,
        this.start,
        this.end,
        this.row1,
        this.row2,
        this.row3,
        this.row4,
        this.row5,
        this.row6,
        this.row7,
        this.row8,
        this.row9});

  GrahList.fromJson(Map<String, dynamic> json) {
    grah = json['Grah'];
    color = json['Color'];
    start = json['Start'];
    end = json['End'];
    row1 = json['Row 1'] != null ? new Row1.fromJson(json['Row 1']) : null;
    row2 = json['Row 2'] != null ? new Row1.fromJson(json['Row 2']) : null;
    row3 = json['Row 3'] != null ? new Row1.fromJson(json['Row 3']) : null;
    row4 = json['Row 4'] != null ? new Row1.fromJson(json['Row 4']) : null;
    row5 = json['Row 5'] != null ? new Row1.fromJson(json['Row 5']) : null;
    row6 = json['Row 6'] != null ? new Row1.fromJson(json['Row 6']) : null;
    row7 = json['Row 7'] != null ? new Row1.fromJson(json['Row 7']) : null;
    row8 = json['Row 8'] != null ? new Row1.fromJson(json['Row 8']) : null;
    row9 = json['Row 9'] != null ? new Row1.fromJson(json['Row 9']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Grah'] = this.grah;
    data['Color'] = this.color;
    data['Start'] = this.start;
    data['End'] = this.end;
    if (this.row1 != null) {
      data['Row 1'] = this.row1!.toJson();
    }
    if (this.row2 != null) {
      data['Row 2'] = this.row2!.toJson();
    }
    if (this.row3 != null) {
      data['Row 3'] = this.row3!.toJson();
    }
    if (this.row4 != null) {
      data['Row 4'] = this.row4!.toJson();
    }
    if (this.row5 != null) {
      data['Row 5'] = this.row5!.toJson();
    }
    if (this.row6 != null) {
      data['Row 6'] = this.row6!.toJson();
    }
    if (this.row7 != null) {
      data['Row 7'] = this.row7!.toJson();
    }
    if (this.row8 != null) {
      data['Row 8'] = this.row8!.toJson();
    }
    if (this.row9 != null) {
      data['Row 9'] = this.row9!.toJson();
    }
    return data;
  }
}

class Row1 {
  String? grah;
  String? color;
  String? start;
  String? end;

  Row1({this.grah, this.color, this.start, this.end});

  Row1.fromJson(Map<String, dynamic> json) {
    grah = json['Grah'];
    color = json['Color'];
    start = json['Start'];
    end = json['End'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Grah'] = this.grah;
    data['Color'] = this.color;
    data['Start'] = this.start;
    data['End'] = this.end;
    return data;
  }
}
