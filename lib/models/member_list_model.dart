class MemberListModel {
  MemberListModel({
    required this.status,
    required this.members,
  });
  late final bool status;
  late final List<Members> members;

  MemberListModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    members = List.from(json['members']).map((e)=>Members.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['members'] = members.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Members {
  Members({
    required this.mID,
    required this.Name,
    required this.Gender,
    required this.DOB,
    required this.City,
  });
  late final String mID;
  late final String Name;
  late final String Gender;
  late final String DOB;
  late final String City;

  Members.fromJson(Map<String, dynamic> json){
    mID = json['mID'];
    Name = json['Name'];
    Gender = json['Gender'];
    DOB = json['DOB'];
    City = json['City'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['mID'] = mID;
    _data['Name'] = Name;
    _data['Gender'] = Gender;
    _data['DOB'] = DOB;
    _data['City'] = City;
    return _data;
  }
}