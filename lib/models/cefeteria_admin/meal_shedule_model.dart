class MealSheduleModel {
  String mealId;
  String userId;
  String? scheduleId;
  String? repeatCount;
  String? repeatEvery;
  List<String> availableAt;
  List<String> repeatOn;

  MealSheduleModel({
    required this.mealId,
    required this.userId,
    this.scheduleId,
    this.repeatCount,
    this.repeatEvery,
    required this.availableAt,
    required this.repeatOn,
  });

  /// Convert ScheduleSelection object to a Map
  Map<String, dynamic> toMap() {
    return {
      'mealId': mealId,
      'userId': userId,
      'scheduleId': scheduleId,
      'repeatCount': repeatCount,
      'repeatEvery': repeatEvery,
      'availableAt': availableAt,
      'repeatOn': repeatOn,
    };
  }

  /// Create a ScheduleSelection object from a Map
  factory MealSheduleModel.fromMap(Map<String, dynamic> map) {
    return MealSheduleModel(
      mealId: map['mealId'] ?? '',
      userId: map['userId'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      repeatCount: map['repeatCount'] ?? '',
      repeatEvery: map['repeatEvery'] ?? '',
      availableAt: List<String>.from(map['availableAt'] ?? []),
      repeatOn: List<String>.from(map['repeatOn'] ?? []),
    );
  }

  /// Convert the object to a formatted string
  @override
  String toString() {
    return 'Meal ID: $mealId | User ID: $userId | Available at: ${availableAt.join(", ")} | Repeat on: ${repeatOn.join(", ")}';
  }
}
