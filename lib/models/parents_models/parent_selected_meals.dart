class ParentSelectedMeals {
  String? mealName;
  String? imageUrl;
  String? mealPrice;
  String? scheduleStatement;
  Schedule? schedule; // Made nullable for safety

  ParentSelectedMeals({
    this.mealName,
    this.imageUrl,
    this.mealPrice,
    this.scheduleStatement,
    this.schedule,
  });

  // Factory constructor for creating an object from a Map (useful for JSON parsing)
  factory ParentSelectedMeals.fromMap(Map<String, dynamic> map) {
    return ParentSelectedMeals(
      mealName: map['mealName'] as String?,
      imageUrl: map['imageUrl'] as String?,
      mealPrice: map['mealPrice'] as String?,
      scheduleStatement: map['scheduleStatement'] as String?,
      schedule: map['schedule'] != null ? Schedule.fromMap(map['schedule']) : null,
    );
  }

  // Convert object to Map (useful for sending data to Firestore or APIs)
  Map<String, dynamic> toMap() {
    return {
      'mealName': mealName,
      'imageUrl': imageUrl,
      'mealPrice': mealPrice,
      'scheduleStatement': scheduleStatement,
      'schedule': schedule?.toMap(),
    };
  }


@override
  String toString() {
    return 'ParentSelectedMeals(mealNames: $mealName,imageUrls: $imageUrl, mealPrices: $mealPrice, scheduleStatements: $scheduleStatement, schedules: $schedule)';
  }
}

class Schedule {
  String? id;
  String? repeatCount;
  String? repeatEvery;
  List<String>? availableAt;
  List<String>? repeatOn;

  Schedule({
    this.id,
    this.repeatCount,
    this.repeatEvery,
    this.availableAt,
    this.repeatOn,
  });

  // Convert JSON (Map) to Schedule object
  factory Schedule.fromMap(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      repeatCount: json['repeatCount'] ?? '',
      repeatEvery: json['repeatEvery'] ?? '',
      availableAt: List<String>.from(json['availableAt'] ?? []),
      repeatOn: List<String>.from(json['repeatOn'] ?? []),
    );
  }

  // Convert Schedule object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'repeatCount': repeatCount,
      'repeatEvery': repeatEvery,
      'availableAt': availableAt ?? [],
      'repeatOn': repeatOn ?? [],
    };
  }

  @override
  String toString() {
    return 'Schedule(id: $id, repeatCount: $repeatCount, repeatEvery: $repeatEvery, availableAt: $availableAt, repeatOn: $repeatOn)';
  }
}
