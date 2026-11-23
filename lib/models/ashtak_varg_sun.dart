class AshtakVargSun {
  bool status;
  String startingRashi;
  List<List<String>> table;

  AshtakVargSun({
    required this.status,
    required this.startingRashi,
    required this.table,
  });

  factory AshtakVargSun.fromJson(Map<String, dynamic> json) {
    var tableJson = json['table'] as List;
    List<List<String>> tableData = tableJson.map((e) => List<String>.from(e)).toList();

    return AshtakVargSun(
      status: json['status'],
      startingRashi: json['starting_rashi'],
      table: tableData,
    );
  }
}

class Planet {
  String title;
  List<String> houses;

  Planet({
    required this.title,
    required this.houses,
  });

  factory Planet.fromJson(List<dynamic> json) {
    return Planet(
      title: json[0],
      houses: List<String>.from(json.sublist(1)),
    );
  }
}
