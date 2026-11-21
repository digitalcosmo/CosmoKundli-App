class AshtakVargModel {
  bool status;
  String startingRashi;
  List<List<String>> table;

  AshtakVargModel({required this.status, required this.startingRashi, required this.table});

  factory AshtakVargModel.fromJson(Map<String, dynamic> json) {
    var tableJson = json['table'] as List;
    List<List<String>> tableData = tableJson.map((e) => List<String>.from(e)).toList();
    return AshtakVargModel(
      status: json['status'],
      startingRashi: json['starting_rashi'],
      table: tableData,
    );
  }
}
