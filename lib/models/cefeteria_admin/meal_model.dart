class MealModel {
  String? id;
  String? userId;
  String? name;
  String? availability;
  String? availableTimeDate;
  String? price;
  String? imageUrl;

  MealModel({this.id, this.userId,this.name, this.availability,this.availableTimeDate, this.price, this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "name": name,
      "availability": availability,
      "availableTimeDate": availableTimeDate,
      "price": price,
      "imageUrl": imageUrl,
    };
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
    );
  }
}
