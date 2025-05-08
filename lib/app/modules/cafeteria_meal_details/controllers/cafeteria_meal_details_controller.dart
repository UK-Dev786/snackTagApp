import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
// import 'package:snacktag/app/routes/app_routes.dart';t';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/meal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CafeteriaMealDetailsController extends GetxController {
  final MealService _mealService = MealService();

  final nameController = TextEditingController();
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
  RxString selectedAvailability = 'available'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is MealModel) {
      meal = Get.arguments as MealModel;
      _populateMealData();
    }
  }

  Future<String?> getUserId() async {
    // First try to get user ID from Firebase Auth
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    print("[addmeal] 👤 Firebase Auth current user ID: $userId");

    // If Firebase Auth doesn't have a user, try from preferences as fallback
    if (userId == null) {
      userId = await userPreferences.getUserId();
      print("[addmeal] 👤 UserPreferences user ID: $userId");
    }

    // Check if userId is still null after both attempts
    if (userId == null) {
      print(
          "[addmeal] ❌ ERROR: User ID is null from both Firebase Auth and UserPreferences");
    }

    return userId;
  }

  void _populateMealData() {
    if (meal != null) {
      nameController.text = meal!.name ?? "";
      selectedAvailability.value = meal!.availability ?? "available";
      availableTimeDateController.text = meal!.availableTimeDate ?? "";
      priceController.text = meal!.price ?? "";
      imageUrl.value = meal!.imageUrl ?? ""; // Set network image URL
    }
  }

  /// Function to save the meal schedule
  Future<void> addMealAndSchedule(MealModel meal, File? imageFile,
      MealSheduleModel schedule, String? userId) async {
    print("[addmeal] 🔄 Starting addMealAndSchedule...");

    // Check if userId is null and try to get it from Firebase Auth
    if (userId == null) {
      userId = FirebaseAuth.instance.currentUser?.uid;
      print("[addmeal] 👤 Firebase Auth current user ID: $userId");

      if (userId == null) {
        print("[addmeal] ❌ ERROR: User ID is null from Firebase Auth");
        throw Exception("User ID not found. Please login again.");
      }
    }

    try {
      print("[addmeal] 📊 Input parameters:");
      print("[addmeal] 📊 meal.userId: ${meal.userId}");
      print("[addmeal] 📊 meal.name: ${meal.name}");
      print("[addmeal] 📊 imageFile: ${imageFile?.path ?? 'null'}");
      print("[addmeal] 📊 schedule.availableAt: ${schedule.availableAt}");
      print("[addmeal] 📊 schedule.repeatOn: ${schedule.repeatOn}");
      print("[addmeal] 📊 userId: $userId");

      // Update meal userId if it's null
      if (meal.userId == null) {
        print("[addmeal] 📊 Updating meal.userId from null to: $userId");
        meal.userId = userId;
      }

      // Step 1: Add meal and get the meal ID
      print("[addmeal] 🔄 Adding meal...");
      String mealId = await _mealService.addMeal(meal, imageFile);
      print("[addmeal] ✅ Meal added with ID: $mealId");

      // Step 2: Assign mealId to the schedule
      print("[addmeal] 🔄 Assigning mealId to schedule...");
      schedule.mealId = mealId;
      schedule.userId = userId;
      print("[addmeal] 📊 Updated schedule.mealId: ${schedule.mealId}");
      print("[addmeal] 📊 Updated schedule.userId: ${schedule.userId}");

      // Step 3: Save meal schedule
      print("[addmeal] 🔄 Saving meal schedule...");
      await _mealService.saveMealSchedule(schedule);
      print("[addmeal] ✅ Meal schedule saved successfully!");
    } catch (e) {
      print("[addmeal] 🔥 Error adding meal and schedule: $e");
      print("[addmeal] 🔥 Stack trace: ${StackTrace.current}");
      throw e; // Re-throw to allow caller to handle
    }
  }

  Future<void> submitMeal() async {
    print("[addmeal] 🔄 Starting meal submission process...");

    // Print controller state variables
    print("[addmeal] 📊 Controller state:");
    print("[addmeal] 📊 nameController.text: ${nameController.text}");
    print(
        "[addmeal] 📊 selectedAvailability.value: ${selectedAvailability.value}");
    print("[addmeal] 📊 priceController.text: ${priceController.text}");
    print(
        "[addmeal] 📊 availableTimeDateController.text: ${availableTimeDateController.text}");
    print(
        "[addmeal] 📊 selectedImage.value: ${selectedImage.value?.path ?? 'null'}");
    print("[addmeal] 📊 imageUrl.value: ${imageUrl.value}");
    print("[addmeal] 📊 isLoading.value: ${isLoading.value}");
    print("[addmeal] 📊 meal: ${meal?.id ?? 'null'}");
    print("[addmeal] 📊 availableAt: $availableAt");
    print("[addmeal] 📊 repeatOn: $repeatOn");

    // Get userId from Firebase Auth first, then fallback to preferences
    final userId = await getUserId();
    print("[addmeal] 👤 User ID retrieved: $userId");

    // Check if userId is null
    if (userId == null) {
      print("[addmeal] ❌ Cannot proceed: User ID is null");
      Get.snackbar("Error", "User ID not found. Please login again.");
      return;
    }

    // Trim text values
    String name = nameController.text.trim();
    print("[addmeal] 📊 name (trimmed): '$name'");

    // Get availability from dropdown
    String availability = selectedAvailability.value;
    print("[addmeal] 📊 availability (from dropdown): '$availability'");

    String price = priceController.text.trim();
    print("[addmeal] 📊 price (trimmed): '$price'");

    String available = availableTimeDateController.text.trim();
    print("[addmeal] 📊 available (trimmed): '$available'");

    print(
        "[addmeal] 📝 Form data: Name=$name, Availability=$availability, Price=$price, AvailableTime=$available");
    print("[addmeal] 📅 Available days: $availableAt");
    print("[addmeal] 🔄 Repeat on days: $repeatOn");

    // Validation
    bool nameEmpty = name.isEmpty;
    bool availableEmpty = available.isEmpty;
    bool priceEmpty = price.isEmpty;

    print("[addmeal] 🔍 Validation checks:");
    print("[addmeal] 🔍 nameEmpty: $nameEmpty");
    print("[addmeal] 🔍 availableEmpty: $availableEmpty");
    print("[addmeal] 🔍 priceEmpty: $priceEmpty");

    if (nameEmpty || availableEmpty || priceEmpty) {
      print("[addmeal] ❌ Validation failed: Empty fields detected");
      Get.snackbar("Validation Error", "All fields are required");
      return;
    }

    // Set loading state
    isLoading.value = true;
    print("[addmeal] 🔄 Set isLoading to true");

    try {
      bool isNewMeal = meal == null;
      print("[addmeal] 📊 isNewMeal: $isNewMeal");

      if (isNewMeal) {
        // Creating a new meal
        print("[addmeal] 🆕 Creating new meal...");

        // Create meal model
        MealModel newMeal = MealModel(
          userId: userId,
          name: name,
          availability: availability,
          price: price,
          availableTimeDate: available,
        );

        print("[addmeal] 📊 newMeal object:");
        print("[addmeal] 📊 newMeal.userId: ${newMeal.userId}");
        print("[addmeal] 📊 newMeal.name: ${newMeal.name}");
        print("[addmeal] 📊 newMeal.availability: ${newMeal.availability}");
        print("[addmeal] 📊 newMeal.price: ${newMeal.price}");
        print(
            "[addmeal] 📊 newMeal.availableTimeDate: ${newMeal.availableTimeDate}");

        // Check image
        bool hasImage = selectedImage.value != null;
        print("[addmeal] 🖼️ Image selected: $hasImage");

        if (hasImage) {
          String imagePath = selectedImage.value!.path;
          int imageSize = await selectedImage.value!.length();
          print("[addmeal] 📁 Image path: $imagePath");
          print("[addmeal] 📏 Image size: $imageSize bytes");
        }

        // Add meal
        print("[addmeal] 🔄 Calling MealService.addMeal()...");
        String mealId =
            await _mealService.addMeal(newMeal, selectedImage.value);
        print("[addmeal] ✅ Meal added successfully with ID: $mealId");

        // Create schedule model
        print("[addmeal] 📊 Creating meal schedule with:");
        print("[addmeal] 📊 mealId: $mealId");
        print("[addmeal] 📊 userId: $userId");
        print("[addmeal] 📊 availableAt: $availableAt");
        print("[addmeal] 📊 repeatOn: $repeatOn");

        MealSheduleModel mealSchedule = MealSheduleModel(
          mealId: mealId,
          userId: userId,
          availableAt: availableAt.toList(),
          repeatOn: repeatOn.toList(),
        );

        print("[addmeal] 📊 mealSchedule object created:");
        print("[addmeal] 📊 mealSchedule.mealId: ${mealSchedule.mealId}");
        print("[addmeal] 📊 mealSchedule.userId: ${mealSchedule.userId}");
        print(
            "[addmeal] 📊 mealSchedule.availableAt: ${mealSchedule.availableAt}");
        print("[addmeal] 📊 mealSchedule.repeatOn: ${mealSchedule.repeatOn}");

        // Save schedule
        print("[addmeal] 🔄 Saving meal schedule...");
        await _mealService.saveMealSchedule(mealSchedule);
        print("[addmeal] ✅ Meal schedule saved successfully");

        Get.snackbar("Success", "Meal saved successfully!");
      } else {
        // Updating an existing meal
        String mealId = meal!.id!;
        print("[addmeal] 🔄 Updating existing meal with ID: $mealId");

        // Create update data
        Map<String, dynamic> updateData = {
          "userId": userId,
          "name": name,
          "availability": availability,
          "price": price,
        };

        print("[addmeal] 📊 updateData:");
        updateData.forEach((key, value) {
          print("[addmeal] 📊 updateData[$key]: $value");
        });

        // Check for new image
        bool hasNewImage = selectedImage.value != null;
        print("[addmeal] 📊 hasNewImage: $hasNewImage");

        if (hasNewImage) {
          String imagePath = selectedImage.value!.path;
          int imageSize = await selectedImage.value!.length();
          print("[addmeal] 🖼️ New image selected for update: $imagePath");
          print("[addmeal] 📏 Image size: $imageSize bytes");
          updateData["imageUrl"] = imagePath;
          print(
              "[addmeal] 📊 Added imageUrl to updateData: ${updateData['imageUrl']}");
        }

        // Update meal
        print("[addmeal] 🔄 Calling MealService.updateMeal() with ID: $mealId");
        await _mealService.updateMeal(mealId, updateData);
        print("[addmeal] ✅ Meal updated successfully");
      }

      // Navigation
      String nextRoute = Routes.CAFETERIA_LANDING_PAGE;
      print("[addmeal] 🔄 Navigating to: $nextRoute");
      Get.offAndToNamed(nextRoute);
    } catch (e) {
      print("[addmeal] ❌ Error in submitMeal(): $e");
      print("[addmeal] ❌ Stack trace: ${StackTrace.current}");
      Get.snackbar("Error", "Failed to save meal. Please try again.");
    } finally {
      // Reset loading state
      isLoading.value = false;
      print("[addmeal] 🔄 Set isLoading back to false");
      print("[addmeal] 🏁 Meal submission process completed");
    }
  }

  Future<void> pickImage() async {
    print("[addmeal] 🔄 Starting image picker...");
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print("[addmeal] ✅ Image picked successfully: ${pickedFile.path}");
        print(
            "[addmeal] 📏 Image size: ${await File(pickedFile.path).length()} bytes");
        selectedImage.value = File(pickedFile.path);
        imageUrl.value =
            ''; // Clear the old network image when new one is picked
        print(
            "[addmeal] 🔄 Image set to selectedImage and old imageUrl cleared");
      } else {
        print("[addmeal] ℹ️ No image selected by user");
      }
    } catch (e) {
      print("[addmeal] ❌ Error picking image: $e");
      Get.snackbar("Error", "Failed to pick image. Please try again.");
    }
  }
}
