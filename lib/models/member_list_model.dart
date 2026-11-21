class MemberListModel {
  late final bool status;
  late final List<Members> members;

  MemberListModel({required this.status, required this.members});

  MemberListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    members = List.from(json['members']).map((e) => Members.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'members': members.map((e) => e.toJson()).toList(),
  };
}

class Members {
  late final String mID;
  late final String Name;
  late final String Gender;
  late final String DOB;
  late final String City;

  Members({required this.mID, required this.Name, required this.Gender, required this.DOB, required this.City});

  Members.fromJson(Map<String, dynamic> json) {
    mID = json['mID'];
    Name = json['Name'];
    Gender = json['Gender'];
    DOB = json['DOB'];
    City = json['City'];
  }

  Map<String, dynamic> toJson() => {'mID': mID, 'Name': Name, 'Gender': Gender, 'DOB': DOB, 'City': City};
}
