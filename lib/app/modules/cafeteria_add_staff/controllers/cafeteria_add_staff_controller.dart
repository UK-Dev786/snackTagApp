import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/validation.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/cefeteria_admin_services/add_staff_service.dart';

class CafeteriaAddStaffController extends GetxController {
  final AddStaffService _addStaffService = AddStaffService();
  //TODO: Implement CafeteriaAddStaffController
  var nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool isLoading = false.obs;
  StaffModel? staffData;
  Rx<File?> selectedImage = Rx<File?>(null);
  RxString imageUrl = ''.obs;
  final UserPreferences userPreferences = UserPreferences();
// ------  update and delete the staff data
  var staffDataList = <StaffModel>[].obs;
  // --------------- end update delete data
  String staffName = '';

  @override
  void onInit() {
    fetchStaffData();

    super.onInit();
    print("object");
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      imageUrl.value = ''; // Clear the old network image when new one is picked
    }
  }

  // Function to handle form submission and save data
  Future<void> addStaffData() async {
    print("📌 Starting addStaffData method");

    // Get current user ID from Firebase Auth instead of preferences
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    print("📌 Firebase Auth current user ID: $userId");

    // If Firebase Auth doesn't have a user, try from preferences as fallback
    if (userId == null) {
      userId = await userPreferences.getUserId();
      print("📌 UserPreferences user ID: $userId");
    }

    // Check if userId is still null after both attempts
    if (userId == null) {
      print(
          "❌ ERROR: User ID is null from both Firebase Auth and UserPreferences");
      Get.snackbar("Error", "User ID not found. Please login again.");
      return;
    }

    print("✅ Using user ID: $userId");

    // Replace with actual user ID from authentication
    String staffName = nameController.text.trim();
    String staffEmail = emailController.text.trim();
    String staffPhone = phoneController.text.trim();
    String staffPassword = passwordController.text.trim();

    print(
        "📌 Staff data to be added: Name=$staffName, Email=$staffEmail, Phone=$staffPhone");

    // Validate input data before saving
    if (staffName.isEmpty ||
        staffEmail.isEmpty ||
        staffPhone.isEmpty ||
        staffPassword.isEmpty) {
      print("❌ Validation failed: Empty fields");
      Get.snackbar("Validation Error", "All fields are required");
      return;
    }

    if (!(Validator.isValidEmail(staffEmail))) {
      print("❌ Validation failed: Invalid email format");
      Get.snackbar("Validation Error", "Please Enter Valid Email");
      return;
    }

    isLoading.value = true;
    try {
      if (staffData == null) {
        // create new model
        print("📌 Creating new staff with user ID: $userId");

        // Check if phone number exists
        bool phoneExists =
            await _addStaffService.isPhoneNumberExists(phoneController.text);
        print("📌 Phone number exists check: $phoneExists");

        if (phoneExists) {
          print("❌ Phone number already registered");
          Get.snackbar(
            "Phone Number Exists",
            "This phone number is already registered.",
          );
          isLoading.value = false;
          return;
        }

        StaffModel newModel = StaffModel(
          staffPassword: staffPassword,
          staffEmail: staffEmail,
          staffName: staffName,
          staffPhone: staffPhone,
          userId: userId,
        );

        print("📌 Staff model created, proceeding to save to Firestore");

        // Call the service method to save data to Firestore
        await _addStaffService
            .addStaff(newModel, selectedImage.value, userId)
            .then((result) {
          print("✅ Staff added successfully");
          Get.back();
          Get.offNamed(Routes.CAFETERIA_STAFF_LIST);

          nameController.text = '';
          emailController.text = '';
          phoneController.text = '';
          passwordController.text = '';
          selectedImage.value = null;
          imageUrl.value = '';
        });
      }
      //for updating staff data
      else {
        print("📌 Updating existing staff data");
        // Add update logic here
      }

      // Optional: Show success message using GetX
      print("✅ Operation completed successfully");
      Get.snackbar('Success', 'Staff data saved successfully');
    } catch (e) {
      // Handle errors
      print("❌ ERROR: Failed to save staff data: $e");
      Get.snackbar("Error", "Failed to save Staff. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // fetch the staff data
  void fetchStaffData() async {
    print("📌 Starting fetchStaffData method");

    // Try to get user ID from Firebase Auth first
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    print("📌 Firebase Auth current user ID: $userId");

    // If Firebase Auth doesn't have a user, try from preferences as fallback
    if (userId == null) {
      userId = await userPreferences.getUserId();
      print("📌 UserPreferences user ID: $userId");
    }

    if (userId == null) {
      print(
          "❌ ERROR: User ID is null from both Firebase Auth and UserPreferences");
      Get.snackbar("Error", "User ID not found. Please login again.");
      return;
    }

    print("✅ Using user ID: $userId");

    isLoading.value = true;
    try {
      print("📌 Binding stream to fetch staff data for user ID: $userId");
      // bind the stream to the staff list
      staffDataList.bindStream(_addStaffService.fetchStaffData(userId));

      // Add a listener to handle empty staff list case
      ever(staffDataList, (list) {
        if (list.isEmpty) {
          print("📌 No staff data found for user ID: $userId");
          // You can set a flag here if needed to show "Add Staff" UI
        } else {
          print("✅ Found ${list.length} staff members for user ID: $userId");
        }
      });
    } catch (e) {
      print("❌ ERROR: Failed to fetch staff data: $e");
      Get.snackbar("Error", "Failed to fetch staff data");
    } finally {
      isLoading.value = false; // Set loading to false when data is received
    }
  }

  void deleteStaffData(String staffId) async {
    await _addStaffService.deleteStaffData(staffId);
    fetchStaffData();
  }
}
