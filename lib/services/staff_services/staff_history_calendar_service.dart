import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/base_service.dart';

class StaffHistoryCalendarService extends BaseService{
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
  Future<List<ParentsAddChildren>> fetchChildrenByIds(List<String> studentIds) async {
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


}