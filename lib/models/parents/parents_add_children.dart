// class ParentsAddChildren {
//   String? id;
//   String? parentId;
//   String? childId;
//   String? childName;
//   String? childGender; // Added gender field
//   String? childSchoolID;
//   String? schoolName;
//   String? cafeteriaName;
//   String? classroomDelivery;
//   String? numberOfChildren;
//   String? allChildrenAreInSameSchool;
//   String? date;
//   String? childImageUrl;
//   List<SelectedMealMenuData>? selectedMealMenuData;

//   ParentsAddChildren({
//     this.id,
//     this.parentId,
//     this.childId,
//     this.childName,
//     this.childGender, // Added to constructor
//     this.childSchoolID,
//     this.schoolName,
//     this.cafeteriaName,
//     this.classroomDelivery,
//     this.numberOfChildren,
//     this.allChildrenAreInSameSchool,
//     this.date,
//     this.childImageUrl,
//     this.selectedMealMenuData,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'parentId': parentId,
//       'childId': childId,
//       'childName': childName,
//       'childGender': childGender, // Added to JSON conversion
//       'childSchoolID': childSchoolID,
//       'schoolName': schoolName,
//       'cafeteriaName': cafeteriaName,
//       'classroomDelivery': classroomDelivery,
//       'numberOfChildren': numberOfChildren,
//       'allChildrenAreInSameSchool': allChildrenAreInSameSchool,
//       'date': date,
//       'childImageUrl': childImageUrl,
//       'selectedMealMenuData': selectedMealMenuData?.map((e) => e.toJson()).toList(),
//     };
//   }
// }
