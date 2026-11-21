import 'package:cosmo_kundli/models/kundali_model.dart';

class VargKundalisModel {
  bool? status;
  List<KundaliModel>? kundaliModel;

  VargKundalisModel({this.status, this.kundaliModel});

  VargKundalisModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['planets'] != null) {
      kundaliModel = <KundaliModel>[];
      json['planets'].forEach((v) {
        kundaliModel!.add(KundaliModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'planets': kundaliModel?.map((v) => v.toJson()).toList(),
  };
}
