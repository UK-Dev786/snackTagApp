import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/parents/add_children_service.dart';
import 'package:snacktag/services/parents/school_cafaterias_model.dart';

class MenuPageController extends GetxController {
  //TODO: Implement CafeteriaController
  final AddChildrenService addChildrenService = AddChildrenService();
  var selectedIndexes = <int>{}.obs;
  var scheduleModel = <MealSheduleModel>[].obs;
  var cafeteriaId = ''.obs;
  var isLoading = false.obs;
  var meals = <MealModel>[].obs;
  var searchText = "".obs;
  var filteredMeals = <MealModel>[].obs;
  var isDataFound = false.obs;
  File? childImageFile;
  var scheduleStatementList = <String>[].obs;
// Initialize list
  var childData = ParentsAddChildren();
  var cafeModel = <CafeteriaDetailsParents>[]; // Initialize list
  File? imageFile;
  TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    // Get arguments from previous screen
    final Map<String, dynamic>? args = Get.arguments;

    if (args != null) {
      // Retrieve cafeId
      String cafeId = args["cafeId"];
      cafeteriaId.value = cafeId;
      cafeModel = args["cafeData"] as List<CafeteriaDetailsParents>;
      // Retrieve childData and cast it properly
      childData = args["childData"] as ParentsAddChildren;

      // Retrieve image file
       imageFile = args["imageFile"] as File?;

    }
    print("cafeteria user id: ${cafeteriaId.value}");
    fetchMeals(cafeteriaId.value);
  }

  void fetchMeals(String cafeId) {
    isLoading.value = true;

    meals.bindStream(addChildrenService.getMealsByCafeteriaUser(cafeId));

    meals.listen((_) {
      print("Fetched School Data: $meals");
      filterMeals();
      isLoading.value = false; // Set loading to false only after data loads
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
}
