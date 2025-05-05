// class ParentChildrenModel {
//   String parentId;
//   List<ChildModel> children;
//
//   ParentChildrenModel({
//     required this.parentId,
//     required this.children,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'parentId': parentId,
//       'children': children.map((child) => child.toJson()).toList(),
//     };
//   }
//
//   factory ParentChildrenModel.fromJson(Map<String, dynamic> json) {
//     return ParentChildrenModel(
//       parentId: json['parentId'] ?? '',
//       children: (json['children'] as List<dynamic>?)
//           ?.map((child) => ChildModel.fromJson(child))
//           .toList() ??
//           [],
//     );
//   }
// }
// class ChildModel {
//   String id;
//   String name;
//   String schoolId;
//   String schoolName;
//
//   ChildModel({
//     required this.id,
//     required this.name,
//     required this.schoolId,
//     required this.schoolName,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'schoolId': schoolId,
//       'schoolName': schoolName,
//     };
//   }
//
//   factory ChildModel.fromJson(Map<String, dynamic> json) {
//     return ChildModel(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       schoolId: json['schoolId'] ?? '',
//       schoolName: json['schoolName'] ?? '',
//     );
//   }
// }
