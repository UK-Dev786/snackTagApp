import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/base_service.dart';

class CafeteriaChildVerificationService extends BaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<ParentsAddChildren>> fetchChildrenBySchoolId(
      String childSchoolId) async {
    try {
      // Trim the input to remove any leading/trailing spaces
      String trimmedChildSchoolId = childSchoolId;

      // Get all documents to find matching school ID pattern
      QuerySnapshot<Map<String, dynamic>> allChildrenSnapshot =
          await firestore.collection("parentsChildren").get();

      List<ParentsAddChildren> childrenList = [];

      // Process each document to find matches
      for (var doc in allChildrenSnapshot.docs) {
        Map<String, dynamic> data = doc.data();

        // Get the school name and child school ID from the document
        String? schoolName = data['schoolName'];
        String? docChildSchoolId = data['childSchoolID'];

        // Skip if either is null
        if (schoolName == null || docChildSchoolId == null) continue;

        // Create the same ID format as used when creating the child
        String formattedId =
            '${schoolName.replaceAll(' ', '_')}_${docChildSchoolId.trim()}';

        // Check if this matches our search criteria
        if (formattedId
                .toLowerCase()
                .contains(trimmedChildSchoolId.toLowerCase()) ||
            docChildSchoolId.trim().toLowerCase() ==
                trimmedChildSchoolId.toLowerCase()) {
          print("Document ID: ${doc.id}");
          print("Data: ${doc.data()}");

          // Add to our results
          childrenList.add(ParentsAddChildren.fromJson(data));
        }
      }

      if (childrenList.isEmpty) {
        print(
            "No matching documents found for childSchoolId: $trimmedChildSchoolId");
      } else {
        print("Found ${childrenList.length} matching children");
      }

      return childrenList;
    } catch (e) {
      print("Error fetching children: $e");
      return [];
    }
  }
}
