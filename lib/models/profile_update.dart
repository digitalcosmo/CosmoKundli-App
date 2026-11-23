class ProfileUpdate {
  bool? status;
  String? message;

  ProfileUpdate({this.status, this.message});

  ProfileUpdate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['Message'] = this.message;
    return data;
  }
}
