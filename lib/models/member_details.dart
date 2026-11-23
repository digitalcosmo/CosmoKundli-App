class MemberDetails {
  bool? status;
  String? firstName;
  String? middleName;
  String? surname;
  String? countryCode;
  String? mobile;
  String? gender;
  String? dob;
  String? btimeHrs;
  String? btimeMin;
  String? btimeSec;
  String? birthPlace;
  String? latitude;
  String? longitude;
  String? timmDiff;

  MemberDetails(
      {this.status,
        this.firstName,
        this.middleName,
        this.surname,
        this.countryCode,
        this.mobile,
        this.gender,
        this.dob,
        this.btimeHrs,
        this.btimeMin,
        this.btimeSec,
        this.birthPlace,
        this.latitude,
        this.longitude,
        this.timmDiff});

  MemberDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    surname = json['surname'];
    countryCode = json['country_code'];
    mobile = json['mobile'];
    gender = json['gender'];
    dob = json['dob'];
    btimeHrs = json['btime_hrs'];
    btimeMin = json['btime_min'];
    btimeSec = json['btime_sec'];
    birthPlace = json['birth_place'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    timmDiff = json['timm_diff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['surname'] = this.surname;
    data['country_code'] = this.countryCode;
    data['mobile'] = this.mobile;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['btime_hrs'] = this.btimeHrs;
    data['btime_min'] = this.btimeMin;
    data['btime_sec'] = this.btimeSec;
    data['birth_place'] = this.birthPlace;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['timm_diff'] = this.timmDiff;
    return data;
  }
}
