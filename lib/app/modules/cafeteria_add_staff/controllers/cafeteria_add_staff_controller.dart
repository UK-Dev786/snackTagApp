import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
// // import 'package:snacktag/app/routes/app_routes.dart';
import 'package:snacktag/config/validation.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/cefeteria_admin_services/add_staff_service.dart';

class CafeteriaAddStaffController extends GetxController {
  final AddStaffService _addStaffService = AddStaffService();

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
    print("[AddStaffScreen] Starting addStaffData method");

    // Get current user ID directly from Firebase Auth
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser == null) {
      print(
          "[AddStaffScreen] ERROR: No authenticated user found in Firebase Auth");
      Get.snackbar("Error", "You are not logged in. Please login again.");
      return;
    }

    String userId = currentUser.uid;
    print("[AddStaffScreen] Firebase Auth current user ID: $userId");

    print("[AddStaffScreen] Using user ID: $userId");

    // Replace with actual user ID from authentication
    String staffName = nameController.text.trim();
    String staffEmail = emailController.text.trim();
    String staffPhone = phoneController.text.trim();
    String staffPassword = passwordController.text.trim();

    print(
        "[AddStaffScreen] Staff data to be added: Name=$staffName, Email=$staffEmail, Phone=$staffPhone");

    // Validation is now handled in the button's onPressed handler

    isLoading.value = true;
    try {
      if (staffData == null) {
        // create new model
        print("[AddStaffScreen] Creating new staff with user ID: $userId");

        // Check if phone number exists
        bool phoneExists =
            await _addStaffService.isPhoneNumberExists(staffPhone);
        print("[AddStaffScreen] Phone number exists check: $phoneExists");

        if (phoneExists) {
          print("[AddStaffScreen] Phone number already registered");
          Get.snackbar(
            "Phone Number Exists",
            "This phone number is already registered.",
          );
          isLoading.value = false;
          return;
        }

        // Check if email exists (optional additional validation)
        bool emailExists = await _addStaffService.isEmailExists(staffEmail);
        print("[AddStaffScreen] Email exists check: $emailExists");

        if (emailExists) {
          print("[AddStaffScreen] Email already registered");
          Get.snackbar(
            "Email Exists",
            "This email is already registered.",
          );
          isLoading.value = false;
          return;
        }

        // Generate a unique ID for the staff
        String staffId =
            FirebaseFirestore.instance.collection("staffData").doc().id;

        StaffModel newModel = StaffModel(
          id: staffId, // Assign the generated ID
          staffPassword: staffPassword,
          staffEmail: staffEmail,
          staffName: staffName,
          staffPhone: staffPhone,
          userId: userId,
        );

        print("[AddStaffScreen] Staff model created: ${newModel.toMap()}");
        print("[AddStaffScreen] Proceeding to save to Firestore");

        // Call the service method to save data to Firestore
        await _addStaffService
            .addStaff(newModel, selectedImage.value, userId)
            .then((result) {
          print(
              "[AddStaffScreen] Staff added successfully with ID: ${newModel.id}");

          // Create a user document for this staff member to enable login
          _createUserDocumentForStaff(newModel);

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
        print("[AddStaffScreen] Updating existing staff data");
        // Add update logic here
      }

      // Optional: Show success message using GetX
      print("[AddStaffScreen] Operation completed successfully");
      Get.snackbar('Success', 'Staff data saved successfully');
    } catch (e) {
      // Handle errors
      print("[AddStaffScreen] ERROR: Failed to save staff data: $e");
      Get.snackbar("Error", "Failed to save Staff. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to create a user document for staff to enable login
  Future<void> _createUserDocumentForStaff(StaffModel staff) async {
    try {
      print(
          "[AddStaffScreen] Creating user document for staff: ${staff.staffName}");

      // Create a document in the users collection for this staff
      await FirebaseFirestore.instance.collection('users').doc(staff.id).set({
        'userId': staff.id,
        'role': 'staff',
        'isStaff': true,
        'staffName': staff.staffName,
        'staffEmail': staff.staffEmail,
        'staffPhone': staff.staffPhone,
        'cafeteriaAdminId': staff.userId, // Link to the cafeteria admin
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(
          "[AddStaffScreen] User document created successfully for staff ID: ${staff.id}");
    } catch (e) {
      print(
          "[AddStaffScreen] ERROR: Failed to create user document for staff: $e");
      // Don't throw here, as we don't want to fail the entire operation
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
