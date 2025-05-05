import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/base_service.dart';

class MealService extends BaseService {
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
    print("[addmeal] 🔄 MealService: Starting addMeal process...");
    
    // Print input parameters
    print("[addmeal] 📊 MealService: Input parameters:");
    print("[addmeal] 📊 MealService: meal.id: ${meal.id ?? 'null'}");
    print("[addmeal] 📊 MealService: meal.userId: ${meal.userId ?? 'null'}");
    print("[addmeal] 📊 MealService: meal.name: ${meal.name ?? 'null'}");
    print("[addmeal] 📊 MealService: meal.availability: ${meal.availability ?? 'null'}");
    print("[addmeal] 📊 MealService: meal.price: ${meal.price ?? 'null'}");
    print("[addmeal] 📊 MealService: meal.availableTimeDate: ${meal.availableTimeDate ?? 'null'}");
    print("[addmeal] 📊 MealService: meal.imageUrl: ${meal.imageUrl ?? 'null'}");
    print("[addmeal] 📊 MealService: imageFile: ${imageFile?.path ?? 'null'}");
    
    // Generate document ID
    String docId = FirebaseFirestore.instance.collection("meals").doc().id;
    print("[addmeal] 📝 MealService: Generated document ID: $docId");

    // Assign the generated ID to the meal model
    meal.id = docId;
    print("[addmeal] 📝 MealService: Assigned ID to meal model: ${meal.id}");

    // Upload image if available
    bool hasImageFile = imageFile != null;
    print("[addmeal] 📊 MealService: hasImageFile: $hasImageFile");
    
    if (hasImageFile) {
      print("[addmeal] 🖼️ MealService: Image file provided, starting upload...");
      String imagePath = imageFile.path;
      int imageSize = await imageFile.length();
      print("[addmeal] 📁 MealService: Image path: $imagePath");
      print("[addmeal] 📏 MealService: Image size: $imageSize bytes");
      
      try {
        // Upload image
        String uploadFolder = "meals";
        print("[addmeal] 📊 MealService: Upload folder: $uploadFolder");
        print("[addmeal] 📊 MealService: Document ID for upload: $docId");
        
        String imageUrl = await uploadImage(imageFile, uploadFolder, docId);
        print("[addmeal] ✅ MealService: Image uploaded successfully");
        print("[addmeal] 🔗 MealService: Image URL: $imageUrl");
        
        // Set image URL in meal model
        meal.imageUrl = imageUrl;
        print("[addmeal] 📊 MealService: Updated meal.imageUrl: ${meal.imageUrl}");
      } catch (e) {
        print("[addmeal] ❌ MealService: Error uploading image: $e");
        print("[addmeal] ❌ MealService: Stack trace: ${StackTrace.current}");
        throw Exception("Failed to upload image: $e");
      }
    } else {
      print("[addmeal] ℹ️ MealService: No image file provided");
    }

    // Save meal to Firestore
    try {
      print("[addmeal] 🔄 MealService: Saving meal data to Firestore...");
      
      // Convert meal to map
      Map<String, dynamic> mealMap = meal.toMap();
      print("[addmeal] 📊 MealService: Meal data map:");
      mealMap.forEach((key, value) {
        print("[addmeal] 📊 MealService: mealMap[$key]: $value");
      });
      
      // Collection and document references
      String collectionPath = "meals";
      print("[addmeal] 📊 MealService: Collection path: $collectionPath");
      print("[addmeal] 📊 MealService: Document ID: $docId");
      
      // Create document
      await createDocument(collectionPath, docId, mealMap);
      print("[addmeal] ✅ MealService: Meal data saved successfully to Firestore");
    } catch (e) {
      print("[addmeal] ❌ MealService: Error saving meal data: $e");
      print("[addmeal] ❌ MealService: Stack trace: ${StackTrace.current}");
      throw Exception("Failed to save meal data: $e");
    }

    // Return the meal ID
    print("[addmeal] 🏁 MealService: addMeal process completed successfully");
    print("[addmeal] 📊 MealService: Returning docId: $docId");
    return docId;
  }

  /// Save Meal Schedule to Firestore
  Future<void> saveMealSchedule(MealSheduleModel mealSchedule) async {
    print("[addmeal] 🔄 MealService: Starting saveMealSchedule process...");
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Generate a unique schedule ID
      String scheduleId = firestore.collection('meal_schedules').doc().id;
      print("[addmeal] 📝 MealService: Generated schedule ID: $scheduleId");

      Map<String, dynamic> scheduleData = mealSchedule.toMap();
      scheduleData['scheduleId'] = scheduleId; // Add scheduleId to Firestore
      
      print("[addmeal] 📝 MealService: Schedule data: $scheduleData");
      print("[addmeal] 🔄 MealService: Saving schedule data to Firestore...");

      // Save to Firestore
      await firestore
          .collection('meal_schedules')
          .doc(scheduleId) // Use generated scheduleId instead of mealId
          .set(scheduleData, SetOptions(merge: true));

      print("[addmeal] ✅ MealService: Meal schedule saved successfully with ID: $scheduleId");
    } catch (e) {
      print("[addmeal] ❌ MealService: Error saving meal schedule: $e");
      print("[addmeal] ❌ MealService: Stack trace: ${StackTrace.current}");
      throw Exception('Failed to save meal schedule: $e');
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

  Stream<List<MealModel>> getMealsByUser(String userId) {
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
