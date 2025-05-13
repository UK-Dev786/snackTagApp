import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/base_service.dart';

class StaffHistoryCalendarService extends BaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<ParentsAddChildren>> fetchChildrenByCafateriaName(
      String cafeteriaName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("parentsChildren")
          .where("cafeteriaName", isEqualTo: cafeteriaName)
          .get();
// Check if data exists
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          print("Document ID: ${doc.id}");
          print("Data: ${doc.data()}");
        }
      } else {
        print("No matching documents found for cafeteriaName: $cafeteriaName");
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

  Future<List<MealModel>> getMealsByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("meals")
          .where("userId", isEqualTo: userId) // ✅ Filter meals by userId
          .get();

      List<MealModel> meals = snapshot.docs.map((doc) {
        print("Fetched Meal: ${doc.data()}");
        return MealModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      return meals;
    } catch (e) {
      print("❌ Error fetching meals: $e");
      return [];
    }
  }

  Future<List<ParentsAddChildren>> fetchChildrenByIds(
      List<String> studentIds) async {
    try {
      print("Fetching children for IDs: $studentIds");

      // Filter out dummy IDs (those starting with "student_")
      List<String> realStudentIds =
          studentIds.where((id) => !id.startsWith("student_")).toList();
      List<String> dummyStudentIds =
          studentIds.where((id) => id.startsWith("student_")).toList();

      print("Real student IDs: $realStudentIds");
      print("Dummy student IDs: $dummyStudentIds");

      // If we have no real student IDs, return an empty list
      if (realStudentIds.isEmpty) {
        print("No real student IDs found, returning empty list");
        return [];
      }

      // Firestore's whereIn can only handle up to 10 values
      // So we need to batch the queries if we have more than 10 IDs
      List<ParentsAddChildren> allChildren = [];

      // Process IDs in batches of 10
      for (int i = 0; i < realStudentIds.length; i += 10) {
        // Get the current batch (up to 10 IDs)
        int endIndex =
            (i + 10 < realStudentIds.length) ? i + 10 : realStudentIds.length;
        List<String> batchIds = realStudentIds.sublist(i, endIndex);

        print("Processing batch ${i ~/ 10 + 1}: $batchIds");

        // Try querying by "id" field first
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
            .collection("parentsChildren")
            .where("id", whereIn: batchIds)
            .get();

        print(
            "Found ${querySnapshot.docs.length} documents in batch ${i ~/ 10 + 1} using 'id' field");

        // If we didn't find any documents, try querying by "childId" field
        if (querySnapshot.docs.isEmpty) {
          print("No documents found using 'id' field, trying 'childId' field");
          querySnapshot = await firestore
              .collection("parentsChildren")
              .where("childId", whereIn: batchIds)
              .get();

          print(
              "Found ${querySnapshot.docs.length} documents in batch ${i ~/ 10 + 1} using 'childId' field");
        }

        // Add the children from this batch to our result list
        for (var doc in querySnapshot.docs) {
          var data = doc.data();
          print("Processing document: ${doc.id} with data: $data");
          allChildren.add(ParentsAddChildren.fromJson(data));
        }
      }

      print("Total children found: ${allChildren.length}");
      return allChildren;
    } catch (e) {
      print("Error fetching children: $e");
      throw Exception("Failed to fetch children data: $e");
    }
  }

  Future<List<ParentsAddChildren>> fetchChildrenByMealName(
      String mealName) async {
    try {
      print("Fetching children for meal name: $mealName");

      // Get all children from parentsChildren collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firestore.collection("parentsChildren").get();

      print("Found ${querySnapshot.docs.length} total children documents");

      List<ParentsAddChildren> childrenWithMeal = [];

      // Filter children who have the specified meal in their selectedMealMenuData
      for (var doc in querySnapshot.docs) {
        try {
          var data = doc.data();
          ParentsAddChildren child = ParentsAddChildren.fromJson(data);

          // Check if child has selectedMealMenuData
          if (child.selectedMealMenuData != null &&
              child.selectedMealMenuData!.isNotEmpty) {
            // Check if any meal in selectedMealMenuData matches the specified meal name
            bool hasMeal = child.selectedMealMenuData!
                .any((meal) => meal.mealName == mealName);

            if (hasMeal) {
              print(
                  "Found child with meal: ${child.childName} (ID: ${child.id})");
              childrenWithMeal.add(child);
            }
          }
        } catch (e) {
          print("Error processing child document: $e");
        }
      }

      print("Total children with meal '$mealName': ${childrenWithMeal.length}");
      return childrenWithMeal;
    } catch (e) {
      print("Error fetching children by meal name: $e");
      throw Exception("Failed to fetch children data by meal name: $e");
    }
  }
}
