import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/base_service.dart';

class ParentsUpcomingDetailService extends BaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   Future<List<ParentsAddChildren>> fetchChildrenByCafateriaName(
//       String cafeteriaName) async {
//
//     try {
//       QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
//           .collection("parentsChildren")
//           .where("cafeteriaName", isEqualTo: cafeteriaName)
//           .get();
// // Check if data exists
//       if (querySnapshot.docs.isNotEmpty) {
//         for (var doc in querySnapshot.docs) {
//           print("Document ID: ${doc.id}");
//           print("Data: ${doc.data()}");
//         }
//       } else {
//         print("No matching documents found for cafeteriaName: $cafeteriaName");
//       }
//       List<ParentsAddChildren> childrenList = querySnapshot.docs
//           .map((doc) => ParentsAddChildren.fromJson(doc.data()))
//           .toList();
//
//       return childrenList;
//     } catch (e) {
//       print("Error fetching children: $e");
//       return [];
//     }
//   }
//   Future<List<MealModel>> getMealsByUser(String userId) async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection("meals")
//           .where("userId", isEqualTo: userId) // ✅ Filter meals by userId
//           .get();
//
//       List<MealModel> meals = snapshot.docs.map((doc) {
//         print("Fetched Meal: ${doc.data()}");
//         return MealModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//       }).toList();
//
//       return meals;
//     } catch (e) {
//       print("❌ Error fetching meals: $e");
//       return [];
//     }
//   }
  Future<List<ParentsAddChildren>> fetchChildrenByIds(
      List<String> studentIds) async {
    try {
      print("Fetching children for IDs: $studentIds");

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("parentsChildren")
          .where("id", whereIn: studentIds)
          .get();

      print("Found ${querySnapshot.docs.length} documents");

      List<ParentsAddChildren> children = querySnapshot.docs.map((doc) {
        var data = doc.data();
        print("Processing document: ${doc.id} with data: $data");
        return ParentsAddChildren.fromJson(data);
      }).toList();

      return children;
    } catch (e) {
      print("Error fetching children: $e");
      throw Exception("Failed to fetch children data: $e");
    }
  }

  /// Fetch only the children related to a specific order
  /// This method filters the children by the provided student IDs and meal name
  Future<List<ParentsAddChildren>> fetchChildrenForOrder(
      List<String>? studentIds,
      {String? mealName}) async {
    try {
      if (studentIds == null || studentIds.isEmpty) {
        print("No student IDs provided for order");
        return [];
      }

      print("Fetching children for specific order with IDs: $studentIds");
      if (mealName != null) {
        print("Filtering by meal name: $mealName");
      }

      // Get the current user ID (parent ID)
      String parentId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (parentId.isEmpty) {
        print("No logged-in user found");
        return [];
      }

      print("Parent ID: $parentId");

      // Get all children for this parent
      QuerySnapshot<Map<String, dynamic>> parentChildrenSnapshot =
          await firestore
              .collection("parentsChildren")
              .where("parentId", isEqualTo: parentId)
              .get();

      print(
          "Found ${parentChildrenSnapshot.docs.length} total children for parent");

      List<ParentsAddChildren> result = [];

      // Process each child document
      for (var doc in parentChildrenSnapshot.docs) {
        var data = doc.data();

        // Convert to ParentsAddChildren object to access selectedMealMenuData
        ParentsAddChildren child = ParentsAddChildren.fromJson(data);

        // Skip children with no meal data
        if (child.selectedMealMenuData == null ||
            child.selectedMealMenuData!.isEmpty) {
          print("Child ${child.childName} has no meal data, skipping");
          continue;
        }

        // Check if this child has ordered the specific meal
        bool hasMeal = false;
        if (mealName != null) {
          // Filter by meal name - only include children who ordered this specific meal
          for (var meal in child.selectedMealMenuData!) {
            if (meal.mealName == mealName) {
              print("✅ Child ${child.childName} has ordered meal: $mealName");
              hasMeal = true;
              break;
            }
          }

          if (!hasMeal) {
            print(
                "❌ Child ${child.childName} has not ordered meal: $mealName, skipping");
            continue;
          }
        }

        // If we get here, the child has the meal we're looking for
        // Now check if this child's ID is in the studentIds list
        String childId = child.id ?? '';
        String alternateChildId = child.childId ?? '';

        bool idMatches = studentIds.any((id) =>
            id.trim() == childId.trim() ||
            (alternateChildId.isNotEmpty &&
                id.trim() == alternateChildId.trim()));

        if (idMatches) {
          print("✅ Child ${child.childName} matches both meal and ID criteria");
          result.add(child);
        } else {
          print("❌ Child ${child.childName} has the meal but ID doesn't match");
        }
      }

      print(
          "Found ${result.length} children matching both meal and ID criteria");

      // If we didn't find any matches, it might be because we're being too strict
      // Let's try a more lenient approach if result is empty
      if (result.isEmpty && mealName != null) {
        print("No exact matches found, trying more lenient approach");

        // Try again without meal name filtering
        return await fetchChildrenForOrder(studentIds);
      }

      return result;
    } catch (e) {
      print("Error fetching children for order: $e");
      throw Exception("Failed to fetch children data for order: $e");
    }
  }
}
