class UpcomingMealOrder {
  final String? image;
  final String? itemName;
  final String? weekday;
  final int? expectedStudent;
  final List<String>? studentIds;
  final String? itemPrice;

  UpcomingMealOrder({
    this.image,
    this.itemName,
    this.weekday,
    this.expectedStudent,
    this.studentIds,
    this.itemPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "image": image,
      "itemName": itemName,
      "weekday": weekday,
      "expectedStudent": expectedStudent,
      "studentIds": studentIds,
      "itemPrice": itemPrice,
    };
  }
}
