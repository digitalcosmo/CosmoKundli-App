class ProfileDetails {
  bool? status;
  String? name;
  String? gender;
  String? dOB;
  String? email;
  String? mobile;

  ProfileDetails(
      {this.status, this.name, this.gender, this.dOB, this.email, this.mobile});

  ProfileDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    name = json['Name'];
    gender = json['Gender'];
    dOB = json['DOB'];
    email = json['Email'];
    mobile = json['Mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Name'] = this.name;
    data['Gender'] = this.gender;
    data['DOB'] = this.dOB;
    data['Email'] = this.email;
    data['Mobile'] = this.mobile;
    return data;
  }
}
