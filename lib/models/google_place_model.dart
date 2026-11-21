class GooglePlaceModel {
  List<Predictions>? predictions;

  GooglePlaceModel({this.predictions});

  GooglePlaceModel.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = <Predictions>[];
      json['predictions'].forEach((v) { predictions!.add(Predictions.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() => {'predictions': predictions?.map((v) => v.toJson()).toList()};
}

class Predictions {
  String? description;
  String? placeId;
  StructuredFormatting? structuredFormatting;

  Predictions({this.description, this.placeId, this.structuredFormatting});

  Predictions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    placeId = json['place_id'];
    structuredFormatting = json['structured_formatting'] != null
        ? StructuredFormatting.fromJson(json['structured_formatting'])
        : null;
  }

  Map<String, dynamic> toJson() => {
    'description': description, 'place_id': placeId,
    'structured_formatting': structuredFormatting?.toJson(),
  };
}

class StructuredFormatting {
  String? mainText;
  String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    mainText = json['main_text'];
    secondaryText = json['secondary_text'];
  }

  Map<String, dynamic> toJson() => {'main_text': mainText, 'secondary_text': secondaryText};
}
