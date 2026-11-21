class MelapakOppUserList {
  bool? status;
  List<MelapakMember>? members;

  MelapakOppUserList({this.status, this.members});

  MelapakOppUserList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['members'] != null) {
      members = <MelapakMember>[];
      json['members'].forEach((v) { members!.add(MelapakMember.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'status': status, 'members': members?.map((v) => v.toJson()).toList()};
}

class MelapakMember {
  String? oID;
  String? name;
  String? gender;

  MelapakMember({this.oID, this.name, this.gender});

  MelapakMember.fromJson(Map<String, dynamic> json) {
    oID = json['oID'];
    name = json['Name'];
    gender = json['Gender'];
  }

  Map<String, dynamic> toJson() => {'oID': oID, 'Name': name, 'Gender': gender};
}
