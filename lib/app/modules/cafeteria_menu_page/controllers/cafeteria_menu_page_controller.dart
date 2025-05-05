import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/services/meal_service.dart';

class CafeteriaMenuPageController extends GetxController {
  final MealService _mealService = MealService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var meals = <MealModel>[].obs;
  var filteredMeals = <MealModel>[].obs;
  var isDataFound = false.obs;
  var isLoading = false.obs;
  var isButtonLoading = false.obs;
  var searchText = "".obs;
  var schoolName = "".obs;
  var cafeteriaName = "".obs;
  TextEditingController searchTextController = TextEditingController();
  final Map<String, ValueNotifier<bool>> switchControllers = {};

  @override
  void onInit() {
    super.onInit();
    searchText.value = searchTextController.text;
    fetchSchoolName();
    fetchMeals();
  }

  void fetchSchoolName() async {
    final user = _auth.currentUser;

    // Fetch user document from Firestore
    DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
        .collection(CollectionKey.USER_COLLECTION)
        .doc(user!.uid)
        .get();
    print("user value documents splash ${userDoc.exists}");
    final schoolN = userDoc.data()?['schoolName'] as String?;
    final cafeteriaN = userDoc.data()?['cafeteriaName'] as String?;

    if (schoolN != null) {
      print("School kkk name $schoolN");
      schoolName.value = schoolN;
      cafeteriaName.value = cafeteriaN!;
    } else {
      schoolName.value = "School Name Not Available";
      print("School kkk name else $schoolN");
    }
  }

  void fetchMeals() {
    print("School kkk name ???  $schoolName");

    isLoading.value = true;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isEmpty) {
      print("User not logged in");
      isLoading.value = false;
      return;
    }

    meals.bindStream(_mealService.getMealsByUser(userId));

    ever(meals, (_) {
      for (var meal in meals) {
        if (!switchControllers.containsKey(meal.id)) {
          switchControllers[meal.id!] =
              ValueNotifier<bool>(meal.availability == 'available');
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
      filteredMeals.assignAll(meals.where((meal) =>
          meal.name!.toLowerCase().contains(searchText.value.toLowerCase())));
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
    await _mealService.updateMeal(
        mealId, {'availability': isAvailable ? 'available' : 'unavailable'});
    if (switchControllers.containsKey(mealId)) {
      switchControllers[mealId]!.value = isAvailable;
    }
  }

  Future<void> deleteMeal(String mealId) async {
    await _mealService.deleteMeal(mealId);
    fetchMeals();
  }
}
