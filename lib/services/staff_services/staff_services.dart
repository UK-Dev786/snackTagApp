import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/base_service.dart';

class StaffMealService extends BaseService {
  final UserPreferences userPreferences = UserPreferences();

  // Future<void> addMeal(MealModel meal, File? imageFile) async {
  //   String docId = FirebaseFirestore.instance.collection("meals").doc().id;
  //
  //   // Assign the generated ID to the meal model
  //   meal.id = docId;
  //
  //   // Upload image if available
  //   if (imageFile != null) {
  //     meal.imageUrl = await uploadImage(imageFile, "meals", docId);
  //   }
  //
  //   // Save meal to Firestore
  //   await createDocument("meals", docId, meal.toMap());
  // }
  Future<String> addMeal(MealModel meal, File? imageFile) async {
    String docId = FirebaseFirestore.instance.collection("meals").doc().id;

    // Assign the generated ID to the meal model
    meal.id = docId;

    // Upload image if available
    if (imageFile != null) {
      meal.imageUrl = await uploadImage(imageFile, "meals", docId);
    }

    // Save meal to Firestore
    await createDocument("meals", docId, meal.toMap());

    // Return the meal ID
    return docId;
  }

  /// Save Meal Schedule to Firestore
  Future<void> saveMealSchedule(MealSheduleModel mealSchedule) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Generate a unique schedule ID
      String scheduleId = firestore.collection('meal_schedules').doc().id;

      // Save the schedule ID to the model

      Map<String, dynamic> scheduleData = mealSchedule.toMap();
      scheduleData['scheduleId'] = scheduleId; // Add scheduleId to Firestore

      // Save to Firestore
      await firestore
          .collection('meal_schedules')
          .doc(scheduleId) // Use generated scheduleId instead of mealId
          .set(scheduleData, SetOptions(merge: true));

      print("✅ Meal schedule saved successfully with ID: $scheduleId");
    } catch (e) {
      print('🔥 Error saving meal schedule: $e');
      throw Exception('Failed to save meal schedule');
    }
  }

  // Stream<List<MealModel>> getMeals() {
  //   // var userId = await userPreferences.getUserId();
  //
  //   var user = FirebaseAuth.instance.currentUser;
  //   var userId = user?.uid ?? '';
  //   return FirebaseFirestore.instance.collection("meals").snapshots().map(
  //     (snapshot) {
  //       return snapshot.docs.map((doc) {
  //         print("sss#ll ${doc.data()}");
  //
  //         return MealModel.fromMap(doc.id, doc.data());
  //       })    .where((meal) => meal.userId == userId) // Filter based on userId
  //           .toList();
  //     },
  //   );
  // }

  Stream<List<MealModel>> getMealsByUser(String userId, String id) {
    print("user id is $userId");
    return FirebaseFirestore.instance
        .collection("meals")
        .where("userId", isEqualTo: userId) // ✅ Filter meals by userId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print("Fetched Meal: ${doc.data()}");
        return MealModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateMeal(String mealId, Map<String, dynamic> data) async {
    await updateDocument("meals", mealId, data);
  }

  Future<void> deleteMeal(String mealId) async {
    await deleteDocument("meals", mealId);
    await deleteStorage("meals", mealId);
  }
}
