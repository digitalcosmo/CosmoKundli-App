class DisplayDetailsModel {
  bool? status;
  String? name;
  String? message;
  String? address;
  String? email;
  String? mobile;
  String? frontImg;
  String? backImg;

  DisplayDetailsModel(
      {this.status,
        this.name,
        this.message,
        this.address,
        this.email,
        this.mobile,
        this.frontImg,
        this.backImg});

  DisplayDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    name = json['Name'];
    message = json['Message'];
    address = json['Address'];
    email = json['Email'];
    mobile = json['Mobile'];
    frontImg = json['Front_Img'];
    backImg = json['Back_Img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Name'] = this.name;
    data['Message'] = this.message;
    data['Address'] = this.address;
    data['Email'] = this.email;
    data['Mobile'] = this.mobile;
    data['Front_Img'] = this.frontImg;
    data['Back_Img'] = this.backImg;
    return data;
  }
}
