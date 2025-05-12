import 'package:snacktag/models/cefeteria_admin/nutritional_facts_model.dart';

class MealModel {
  String? id;
  String? userId;
  String? name;
  String? availability;
  String? availableTimeDate;
  String? price;
  String? imageUrl;
  String? description;
  NutritionalFactsModel? nutritionalFacts;

  MealModel({
    this.id,
    this.userId,
    this.name,
    this.availability,
    this.availableTimeDate,
    this.price,
    this.imageUrl,
    this.description,
    this.nutritionalFacts,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      "id": id,
      "userId": userId,
      "name": name,
      "availability": availability,
      "availableTimeDate": availableTimeDate,
      "price": price,
      "imageUrl": imageUrl,
      "description": description,
    };

    // Only include nutritional facts if they exist
    if (nutritionalFacts != null) {
      data["nutritionalFacts"] = nutritionalFacts!.toMap();
    }

    return data;
  }

  factory MealModel.fromMap(String id, Map<String, dynamic> data) {
    return MealModel(
      id: id,
      userId: data["userId"],
      name: data["name"] ?? "",
      availability: data["availability"] ?? "",
      availableTimeDate: data["availableTimeDate"] ?? "",
      price: data["price"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      description: data["description"] ?? "",
      nutritionalFacts: data["nutritionalFacts"] != null
          ? NutritionalFactsModel.fromMap(data["nutritionalFacts"])
          : null,
    );
  }
}
