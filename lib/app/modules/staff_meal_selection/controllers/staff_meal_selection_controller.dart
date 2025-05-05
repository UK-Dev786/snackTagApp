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

class StaffMealSelectionController extends GetxController {
  final StaffMealService _mealService = StaffMealService();

  var meals = <MealModel>[].obs;
  var filteredMeals = <MealModel>[].obs;
  var isDataFound = false.obs;
  var isLoading = false.obs;
  var searchText = "".obs;
  TextEditingController searchTextController = TextEditingController();
  final Map<String, ValueNotifier<bool>> switchControllers = {};

  @override
  void onInit() {
    super.onInit();
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
}
