class AppDetails {
  bool? status;
  String? appName;
  String? appCode;
  String? description;
  String? icon;

  AppDetails(
      {this.status, this.appName, this.appCode, this.description, this.icon});

  AppDetails.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    appName = json['App_Name'];
    appCode = json['App_Code'];
    description = json['Description'];
    icon = json['Icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['App_Name'] = this.appName;
    data['App_Code'] = this.appCode;
    data['Description'] = this.description;
    data['Icon'] = this.icon;
    return data;
  }
}
