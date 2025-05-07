// import 'package:get/get.dart';
//
// class StaffMealSelectionController extends GetxController {
//   //TODO: Implement StaffMealSelectionController
//
//   final count = 0.obs;
//   @override
//   void onInit() {
//     super.onInit();
//   }
//
//   @override
//   void onReady() {
//     super.onReady();
//   }
//
//   @override
//   void onClose() {
//     super.onClose();
//   }
//
//   void increment() => count.value++;
// }
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/meal_service.dart';
import 'package:snacktag/services/staff_services/staff_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffMealSelectionController extends GetxController {
  final StaffMealService _mealService = StaffMealService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserPreferences _preferences = UserPreferences();
  
  var meals = <MealModel>[].obs;
  var filteredMeals = <MealModel>[].obs;
  var isDataFound = false.obs;
  var isLoading = false.obs;
  var searchText = "".obs;
  TextEditingController searchTextController = TextEditingController();
  final Map<String, ValueNotifier<bool>> switchControllers = {};
  var schoolName = "School Name".obs;
  
  // Method to capitalize the first letter of each word in a string
  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : '');
    }).join(' ');
  }

  @override
  void onInit() {
    super.onInit();
    fetchSchoolName();
    searchText.value = searchTextController.text;
    fetchMeals();
  }

  void fetchMeals() async {
    UserPreferences preferences = UserPreferences();
    StaffModel? staffModel = await preferences.getStaffDataPreference();
    isLoading.value = true;
    print("User not logged in ${staffModel!.userId}");

    meals.bindStream(_mealService.getMealsByUser(staffModel.userId!, staffModel.id!));

    ever(meals, (_) {
      for (var meal in meals) {
        if (!switchControllers.containsKey(meal.id)) {
          switchControllers[meal.id!] = ValueNotifier<bool>(meal.availability == 'available');
        } else {
          switchControllers[meal.id]!.value = meal.availability == 'available';
        }
      }
      filterMeals();
    });
    isLoading.value = false;
  }

  void filterMeals() {
    if (searchText.value.isEmpty) {
      filteredMeals.assignAll(meals);
      isDataFound.value = false;
    } else {
      filteredMeals.assignAll(
          meals.where((meal) => meal.name!.toLowerCase().contains(searchText.value.toLowerCase())));
      isDataFound.value = filteredMeals.isEmpty;
    }
  }

  void updateSearchText(String text) {
    searchText.value = text;
    filterMeals();
  }

  Future<void> addMeal(MealModel meal, File? imageFile) async {
    await _mealService.addMeal(meal, imageFile);
    fetchMeals();
  }

  Future<void> updateMeal(String mealId, bool isAvailable) async {
    await _mealService
        .updateMeal(mealId, {'availability': isAvailable ? 'available' : 'unavailable'});
    if (switchControllers.containsKey(mealId)) {
      switchControllers[mealId]!.value = isAvailable;
    }
  }

  Future<void> deleteMeal(String mealId) async {
    await _mealService.deleteMeal(mealId);
    fetchMeals();
  }

  Future<void> fetchSchoolName() async {
    try {
      print("[SchoolNameFetch] Starting school name fetch process");
      
      // First get staff data from preferences
      StaffModel? staffData = await _preferences.getStaffDataPreference();
      
      if (staffData == null) {
        print("[SchoolNameFetch] No staff data found in preferences");
        return;
      }
      
      print("[SchoolNameFetch] Staff data retrieved - userId: ${staffData.userId}");
      
      if (staffData.userId == null || staffData.userId!.isEmpty) {
        print("[SchoolNameFetch] Staff userId is null or empty");
        return;
      }
      
      // Get the cafeteria admin document from users collection using staff's userId
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection("users")
          .doc(staffData.userId)
          .get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        print("[SchoolNameFetch] No user document found for userId: ${staffData.userId}");
        return;
      }
      
      print("[SchoolNameFetch] User document retrieved: ${userDoc.data()}");
      
      // Extract school name from the user document
      final schoolNameData = userDoc.data()?['schoolName'] as String?;
      
      if (schoolNameData != null && schoolNameData.isNotEmpty) {
        print("[SchoolNameFetch] School name found: $schoolNameData");
        // Capitalize the school name before setting it
        schoolName.value = capitalizeWords(schoolNameData);
      } else {
        print("[SchoolNameFetch] School name not found in user document");
        schoolName.value = "School Name"; // Default capitalized value
      }
    } catch (e) {
      print("[SchoolNameFetch] Error fetching school name: $e");
      schoolName.value = "School Name"; // Default capitalized value on error
    }
  }
}
