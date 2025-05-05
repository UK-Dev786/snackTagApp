import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/meal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CafeteriaMealDetailsController extends GetxController {
  final MealService _mealService = MealService();

  final nameController = TextEditingController();
  final availabilityController = TextEditingController();
  final availableTimeDateController = TextEditingController();
  final priceController = TextEditingController();
  Rx<File?> selectedImage = Rx<File?>(null);
  RxString imageUrl = ''.obs; // Store the network image URL separately
  RxBool isLoading = false.obs;
  MealModel? meal;
  List<String> availableAt = [];
  List<String> repeatOn = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserPreferences userPreferences = UserPreferences();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is MealModel) {
      meal = Get.arguments as MealModel;
      _populateMealData();
    }
  }

  // Future<String?> getUserId() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('user_Id');
  // }
  void _populateMealData() {
    if (meal != null) {
      nameController.text = meal!.name ?? "";
      availabilityController.text = meal!.availability ?? "";
      availableTimeDateController.text = meal!.availableTimeDate ?? "";
      priceController.text = meal!.price ?? "";
      imageUrl.value = meal!.imageUrl ?? ""; // Set network image URL
    }
  }

  /// Function to save the meal schedule
  Future<void> addMealAndSchedule(
      MealModel meal, File? imageFile, MealSheduleModel schedule, String userId) async {
    try {
      // Step 1: Add meal and get the meal ID
      String mealId = await _mealService.addMeal(meal, imageFile);

      // Step 2: Assign mealId to the schedule
      schedule.mealId = mealId;
      schedule.userId = userId;

      // Step 3: Save meal schedule
      await _mealService.saveMealSchedule(schedule);

      print("✅ Meal and schedule saved successfully!");
    } catch (e) {
      print("🔥 Error adding meal and schedule: $e");
    }
  }

  Future<void> submitMeal() async {
    final userId = await userPreferences.getUserId();

    String name = nameController.text.trim();
    String availability = availabilityController.text.trim();
    String price = priceController.text.trim();
    String available = availableTimeDateController.text.trim();
    print("Available value $available");
    if (name.isEmpty || availability.isEmpty || available.isEmpty || price.isEmpty) {
      Get.snackbar("Validation Error", "All fields are required");
      return;
    }

    isLoading.value = true;
    try {
      if (meal == null) {
        // Creating a new meal
        MealModel newMeal = MealModel(
          userId: userId,
          name: name,
          availability: availability,
          price: price,
          availableTimeDate: available,
        );
        // await _mealService.addMeal(newMeal, selectedImage.value);
        String mealId = await _mealService.addMeal(newMeal, selectedImage.value);

        MealSheduleModel mealSchedule = MealSheduleModel(
          mealId: mealId,
          userId: userId!,
          availableAt: availableAt.toList(),
          repeatOn: repeatOn.toList(),
        );
        await _mealService.saveMealSchedule(mealSchedule);
        Get.snackbar("Success", "Meal saved successfully!");
      } else {
        // Updating an existing meal
        await _mealService.updateMeal(meal!.id!, {
          // Set the user id
          "userId": userId,
          "name": name,
          "availability": availability,
          "price": price,
          if (selectedImage.value != null)
            "imageUrl": selectedImage.value!.path, // Upload new image if selected
        });
      }
      Get.offAndToNamed(Routes.CAFETERIA_LANDING_PAGE);
    } catch (e) {
      Get.snackbar("Error", "Failed to save meal. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      imageUrl.value = ''; // Clear the old network image when new one is picked
    }
  }
}
