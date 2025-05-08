import 'package:snacktag/models/parents_models/parent_selected_meals.dart';

class ParentsAddChildren {
  String? id;
  String? orderPrepId;
  String? parentId;
  String? cafeteriaId;
  String? numberOfChildren;
  String? allChildrenAreInSameSchool;
  String? classroomDelivery;

  String? childId;
  String? childName;
  String? childSchoolID;
  String? childImageUrl;
  String? childGender; // Added gender field

  String? schoolName;
  String? cafeteriaName;
  String? date;
  String? orderPreparationDate;
  String? orderDeliveredTime;
  String? status;
  String? orderPreparedBy;
  String? orderDeliveredBy;

  bool startPreparation;
  bool delivered;

  List<ParentSelectedMeals>? selectedMealMenuData;
  double monthlyExpenditures;

  ParentsAddChildren({
    this.id,
    this.orderPrepId,
    this.parentId,
    this.cafeteriaId,
    this.numberOfChildren,
    this.allChildrenAreInSameSchool,
    this.classroomDelivery,
    this.childId,
    this.childName,
    this.childSchoolID,
    this.childImageUrl,
    this.childGender, // Added to constructor
    this.schoolName,
    this.cafeteriaName,
    this.date,
    this.orderPreparationDate,
    this.orderDeliveredTime,
    this.status,
    this.orderPreparedBy,
    this.orderDeliveredBy,
    this.startPreparation = false,
    this.delivered = false,
    this.selectedMealMenuData,
    this.monthlyExpenditures = 0.0,
  });

  factory ParentsAddChildren.fromJson(Map<String, dynamic> json) {
    return ParentsAddChildren(
      id: json['id'],
      orderPrepId: json['orderPrepId'],
      parentId: json['parentId'],
      cafeteriaId: json['cafeteriaId'],
      numberOfChildren: json['numberOfChildren'],
      classroomDelivery: json['classroomDelivery'],
      allChildrenAreInSameSchool: json['allChildrenAreInSameSchool'],
      childId: json['childId'],
      childName: json['childName'],
      childSchoolID: json['childSchoolID'],
      childImageUrl: json['childImageUrl'],
      childGender: json['childGender'], // Added to fromJson
      schoolName: json['schoolName'],
      cafeteriaName: json['cafeteriaName'],
      date: json['date'],
      orderPreparationDate: json['orderPreparationDate'],
      orderDeliveredTime: json['orderDeliveredTime'],
      status: json['status'],
      orderPreparedBy: json['orderPreparedBy'],
      orderDeliveredBy: json['orderDeliveredBy'],
      startPreparation: json['startPreparation'] ?? false,
      delivered: json['delivered'] ?? false,
      selectedMealMenuData: json['selectedMealMenuData'] != null
          ? (json['selectedMealMenuData'] as List)
              .map((meal) => ParentSelectedMeals.fromMap(meal))
              .toList()
          : null,
      monthlyExpenditures: (json['monthlyExpenditures'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderPrepId': orderPrepId,
      'parentId': parentId,
      'cafeteriaId': cafeteriaId,
      'numberOfChildren': numberOfChildren,
      'classroomDelivery': classroomDelivery,
      'allChildrenAreInSameSchool': allChildrenAreInSameSchool,
      'childId': childId,
      'childName': childName,
      'childSchoolID': childSchoolID,
      'childImageUrl': childImageUrl,
      'childGender': childGender, // Added to toJson
      'schoolName': schoolName,
      'cafeteriaName': cafeteriaName,
      'date': date ?? DateTime.now().toIso8601String(),
      'orderPreparationDate': orderPreparationDate,
      'orderDeliveredTime': orderDeliveredTime,
      'status': status,
      'orderPreparedBy': orderPreparedBy,
      'orderDeliveredBy': orderDeliveredBy,
      'startPreparation': startPreparation,
      'delivered': delivered,
      'selectedMealMenuData':
          selectedMealMenuData?.map((meal) => meal.toMap()).toList(),
      'monthlyExpenditures': monthlyExpenditures,
    };
  }
}

// import 'package:snacktag/models/parents_models/parent_selected_meals.dart';
//
// class ParentsAddChildren {
//    String? id;
//    String? parentId;
//    String? numberOfChildren;
//    String? allChildrenAreInSameSchool;
//    String? classroomDelivery;
//
//    String? childId;
//    String? childName;
//    String? childSchoolID;
//    String? childImageUrl;
//
//    String? schoolName;
//    String? cafeteriaName;
//
//    List<ParentSelectedMeals>? selectedMealMenuData; // Changed to List
//
//   ParentsAddChildren({
//     this.id,
//     this.parentId,
//     this.numberOfChildren,
//     this.allChildrenAreInSameSchool,
//     this.classroomDelivery,
//     this.childId,
//     this.childName,
//     this.childSchoolID,
//     this.childImageUrl,
//     this.schoolName,
//     this.cafeteriaName,
//     this.selectedMealMenuData,
//   });
//
//   factory ParentsAddChildren.fromJson(Map<String, dynamic> json) {
//     return ParentsAddChildren(
//       parentId: json['parentId'],
//       id: json['id'],
//       numberOfChildren: json['numberOfChildren'],
//       classroomDelivery: json['classroomDelivery'],
//       allChildrenAreInSameSchool: json['allChildrenAreInSameSchool'],
//       childId: json['childId'],
//       childName: json['childName'],
//       childSchoolID: json['childSchoolID'],
//       childImageUrl: json['childImageUrl'],
//       schoolName: json['schoolName'],
//       cafeteriaName: json['cafeteriaName'],
//       selectedMealMenuData: json['selectedMealMenuData'] != null
//           ? (json['selectedMealMenuData'] as List)
//           .map((meal) => ParentSelectedMeals.fromMap(meal))
//           .toList()
//           : [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'parentId': parentId,
//       'id': id,
//       'numberOfChildren': numberOfChildren,
//       'classroomDelivery': classroomDelivery,
//       'allChildrenAreInSameSchool': allChildrenAreInSameSchool,
//       'childId': childId,
//       'childName': childName,
//       'childSchoolID': childSchoolID,
//       'childImageUrl': childImageUrl,
//       'schoolName': schoolName,
//       'cafeteriaName': cafeteriaName,
//       'selectedMealMenuData': selectedMealMenuData?.map((meal) => meal.toMap()).toList(),
//     };
//   }
// }
