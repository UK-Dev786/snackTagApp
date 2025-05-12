class NutritionalFactsModel {
  String? calories;
  String? protein;
  String? fat;
  String? saturatedFat;
  String? carbohydrates;
  String? fiber;
  String? sugars;
  String? sodium;
  String? cholesterol;

  NutritionalFactsModel({
    this.calories,
    this.protein,
    this.fat,
    this.saturatedFat,
    this.carbohydrates,
    this.fiber,
    this.sugars,
    this.sodium,
    this.cholesterol,
  });

  Map<String, dynamic> toMap() {
    return {
      "calories": calories,
      "protein": protein,
      "fat": fat,
      "saturatedFat": saturatedFat,
      "carbohydrates": carbohydrates,
      "fiber": fiber,
      "sugars": sugars,
      "sodium": sodium,
      "cholesterol": cholesterol,
    };
  }

  factory NutritionalFactsModel.fromMap(Map<String, dynamic> data) {
    return NutritionalFactsModel(
      calories: data["calories"] ?? "",
      protein: data["protein"] ?? "",
      fat: data["fat"] ?? "",
      saturatedFat: data["saturatedFat"] ?? "",
      carbohydrates: data["carbohydrates"] ?? "",
      fiber: data["fiber"] ?? "",
      sugars: data["sugars"] ?? "",
      sodium: data["sodium"] ?? "",
      cholesterol: data["cholesterol"] ?? "",
    );
  }
}
