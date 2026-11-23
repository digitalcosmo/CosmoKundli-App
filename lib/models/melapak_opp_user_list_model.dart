class MelapakOppUserList {
  bool? status;
  List<Members>? members;

  MelapakOppUserList({this.status, this.members});

  MelapakOppUserList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Members {
  String? oID;
  String? name;
  String? gender;

  Members({this.oID, this.name, this.gender});

  Members.fromJson(Map<String, dynamic> json) {
    oID = json['oID'];
    name = json['Name'];
    gender = json['Gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['oID'] = this.oID;
    data['Name'] = this.name;
    data['Gender'] = this.gender;
    return data;
  }
}
