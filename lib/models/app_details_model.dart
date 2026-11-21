class AppDetailsModel {
  bool? status;
  String? appName;
  String? appCode;
  String? description;
  String? icon;

  AppDetailsModel({this.status, this.appName, this.appCode, this.description, this.icon});

  AppDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    appName = json['App_Name'];
    appCode = json['App_Code'];
    description = json['Description'];
    icon = json['Icon'];
  }

  Map<String, dynamic> toJson() => {
    'status': status, 'App_Name': appName, 'App_Code': appCode,
    'Description': description, 'Icon': icon,
  };
}
