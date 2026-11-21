class DisplayDetailsModel {
  bool? status;
  String? name;
  String? message;
  String? address;
  String? email;
  String? mobile;
  String? frontImg;
  String? backImg;

  DisplayDetailsModel({this.status, this.name, this.message, this.address, this.email, this.mobile, this.frontImg, this.backImg});

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

  Map<String, dynamic> toJson() => {
    'status': status, 'Name': name, 'Message': message, 'Address': address,
    'Email': email, 'Mobile': mobile, 'Front_Img': frontImg, 'Back_Img': backImg,
  };
}
