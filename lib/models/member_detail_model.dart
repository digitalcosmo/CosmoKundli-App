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

  MemberDetails({this.status, this.firstName, this.middleName, this.surname, this.countryCode,
    this.mobile, this.gender, this.dob, this.btimeHrs, this.btimeMin, this.btimeSec,
    this.birthPlace, this.latitude, this.longitude, this.timmDiff});

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

  Map<String, dynamic> toJson() => {
    'status': status, 'first_name': firstName, 'middle_name': middleName,
    'surname': surname, 'country_code': countryCode, 'mobile': mobile,
    'gender': gender, 'dob': dob, 'btime_hrs': btimeHrs, 'btime_min': btimeMin,
    'btime_sec': btimeSec, 'birth_place': birthPlace, 'latitude': latitude,
    'longitude': longitude, 'timm_diff': timmDiff,
  };
}
