class ParentSelectedMeals {
  String? mealName;
  String? mealPrice;
  String? scheduleStatement;
  String? imageUrl;
  Schedule? schedule;
  String? id;
  List<String>? scheduledDates; // Add this field to store scheduled dates

  ParentSelectedMeals({
    this.mealName,
    this.mealPrice,
    this.scheduleStatement,
    this.imageUrl,
    this.schedule,
    this.id,
    this.scheduledDates, // Add to constructor
  });

  // Convert JSON (Map) to ParentSelectedMeals object
  factory ParentSelectedMeals.fromMap(Map<String, dynamic> json) {
    return ParentSelectedMeals(
      mealName: json['mealName'],
      mealPrice: json['mealPrice'],
       id: json['id'],
      scheduleStatement: json['scheduleStatement'],
      imageUrl: json['imageUrl'],
      schedule:
          json['schedule'] != null ? Schedule.fromMap(json['schedule']) : null,
      scheduledDates: json['scheduledDates'] != null
          ? List<String>.from(json['scheduledDates'])
          : null,
    );
  }

  // Convert ParentSelectedMeals object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealName': mealName,
      'mealPrice': mealPrice,
      'scheduleStatement': scheduleStatement,
      'imageUrl': imageUrl,
      'schedule': schedule?.toMap(),
      'scheduledDates': scheduledDates,
    };
  }

  @override
  String toString() {
    return 'ParentSelectedMeals(mealNames: $mealName,imageUrls: $imageUrl, id: $id, mealPrices: $mealPrice, scheduleStatements: $scheduleStatement, schedules: $schedule)';
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
