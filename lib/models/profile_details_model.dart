class ProfileDetails {
  bool? status;
  String? name;
  String? gender;
  String? dOB;
  String? email;
  String? mobile;

  ProfileDetails({this.status, this.name, this.gender, this.dOB, this.email, this.mobile});

  ProfileDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    name = json['Name'];
    gender = json['Gender'];
    dOB = json['DOB'];
    email = json['Email'];
    mobile = json['Mobile'];
  }

  Map<String, dynamic> toJson() => {
    'status': status, 'Name': name, 'Gender': gender,
    'DOB': dOB, 'Email': email, 'Mobile': mobile,
  };
}
