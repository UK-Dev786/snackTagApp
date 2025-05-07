import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snacktag/config/validation.dart';
import 'dart:io';

import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/cefeteria_admin_services/add_staff_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CafeteriaEditStaffController extends GetxController {
  final AddStaffService _addStaffService = AddStaffService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserPreferences userPreferences = UserPreferences();

  var isLoading = false.obs;
  var isImageLoading = false.obs;
  var imageUrl = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['staffModelL'] != null) {
      setStaffData(Get.arguments['staffModelL']); // Corrected
    }
  }

  // Fetch staff details and set the form fields
  void setStaffData(StaffModel staff) {
    print("object name ${staff.staffName}");
    nameController.text = staff.staffName ?? '';
    emailController.text = staff.staffEmail ?? '';
    phoneController.text = staff.staffPhone ?? '';
    passwordController.text = staff.staffPassword ?? '';
    imageUrl.value = staff.imageUrl ?? '';
  }

  // Function to update staff data
  Future<void> editStaffData(String staffId) async {
    print("[StaffUpdate] Starting staff update process for ID: $staffId");
    isLoading(true);

    // Get current user ID directly from Firebase Auth
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;
    
    if (currentUser == null) {
      print("[StaffUpdate] ERROR: No authenticated user found in Firebase Auth");
      Get.snackbar("Error", "You are not logged in. Please login again.");
      isLoading(false);
      return;
    }
    
    String userId = currentUser.uid;
    print("[StaffUpdate] Firebase Auth current user ID: $userId");
    
    // Validate all fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      print("[StaffUpdate] Validation failed: Empty fields detected");
      Get.snackbar("Validation Error", "All fields are required");
      isLoading(false);
      return;
    }
    
    if (!(Validator.isValidEmail(emailController.text))) {
      print("[StaffUpdate] Validation failed: Invalid email format: ${emailController.text}");
      Get.snackbar("Validation Error", "Please Enter Valid Email");
      isLoading(false);
      return;
    }
    
    if (passwordController.text.length < 6) {
      print("[StaffUpdate] Validation failed: Password too short (${passwordController.text.length} chars)");
      Get.snackbar("Validation Error", "Password must be at least 6 characters");
      isLoading(false);
      return;
    }
    
    try {
      print("[StaffUpdate] Creating staff model with updated data");
      print("[StaffUpdate] Name: ${nameController.text}");
      print("[StaffUpdate] Email: ${emailController.text}");
      print("[StaffUpdate] Phone: ${phoneController.text}");
      print("[StaffUpdate] Image URL: ${imageUrl.value}");
      print("[StaffUpdate] User ID: $userId");

      StaffModel newModel = StaffModel(
        id: staffId,
        staffPassword: passwordController.text,
        staffEmail: emailController.text,
        staffName: nameController.text,
        staffPhone: phoneController.text,
        userId: userId,
        imageUrl: imageUrl.value
      );
      
      print("[StaffUpdate] Staff model created: ${newModel.toMap()}");
      print("[StaffUpdate] Calling service to update Firestore");
      
      await _addStaffService.editStaffData(userId, staffId, newModel.toMap()).then((val){
        print("[StaffUpdate] Firestore update completed successfully");
        isLoading(false);
      });
      
      print("[StaffUpdate] Staff data updated successfully in Firestore");
      Get.snackbar('Success', 'Staff Data updated successfully');
      
      // Navigate back to previous screen
      print("[StaffUpdate] Navigating back to staff list");
      Get.back();
    } catch (e) {
      print("[StaffUpdate] ERROR: Failed to update staff data: $e");
      print("[StaffUpdate] Stack trace: ${StackTrace.current}");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
      print("[StaffUpdate] Update process completed");
    }
  }

  // Function to pick an image and upload it to Firebase Storage
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = 'staff/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        isImageLoading(true);
        UploadTask uploadTask = _storage.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrl.value = downloadUrl;
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image');
      } finally {
        isImageLoading(false);
      }
    }
  }
}
