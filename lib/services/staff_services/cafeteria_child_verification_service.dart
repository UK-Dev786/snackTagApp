import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/base_service.dart';

class CafeteriaChildVerificationService extends BaseService{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<ParentsAddChildren>> fetchChildrenBySchoolId(
      String childSchoolId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("parentsChildren")
          .where("childSchoolID", isEqualTo: childSchoolId)
          .get();
// Check if data exists
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          print("Document ID: ${doc.id}");
          print("Data: ${doc.data()}");
        }
      } else {
        print("No matching documents found for cafeteriaName: $childSchoolId");
      }
      List<ParentsAddChildren> childrenList = querySnapshot.docs
          .map((doc) => ParentsAddChildren.fromJson(doc.data()))
          .toList();

      return childrenList;
    } catch (e) {
      print("Error fetching children: $e");
      return [];
    }
  }
}