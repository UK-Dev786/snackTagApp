class CafeteriaDetailsParents {
  final String img;
  final String id;
  final String schoolName;
  final String cafeteriaName;

  CafeteriaDetailsParents({
    required this.img,
    required this.id,
    required this.schoolName,
    required this.cafeteriaName,
  });

  /// Factory method to create an instance from a Map
  factory CafeteriaDetailsParents.fromMap(Map<String, dynamic> map) {
    return CafeteriaDetailsParents(
      img: map['img'] ?? '',
      id: map['id'] ?? '',
      schoolName: map['schoolName'] ?? '',
      cafeteriaName: map['cafeteriaName'] ?? '',
    );
  }

  /// Convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'img': img,
      'id': id,
      'schoolName': schoolName,
      'cafeteriaName': cafeteriaName,
    };
  }

  @override
  String toString() {
    return 'CafeteriaDetailsParents(id: $id, schoolName: $schoolName, cafeteriaName: $cafeteriaName, img: $img)';
  }
}
