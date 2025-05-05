import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/staff/staff_profile_update_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffSettingProfileController extends GetxController {
  final StaffProfileUpdateService _staffProfileService = StaffProfileUpdateService();
  final UserPreferences preferences = UserPreferences();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form Controllers
  final nameController = TextEditingController();

  // Reactive Variables
  final staffModel = Rxn<StaffModel>();
  final selectedImage = Rxn<File>();
  final currentImageUrl = RxnString();
  final isLoading = false.obs;
  final isImageLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      final data = await preferences.getStaffDataPreference();
      if (data != null) {
        staffModel.value = data;
        _initializeFormData(data);
      }
    } catch (e) {
      _handleError('Error loading data', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeFormData(StaffModel data) {
    nameController.text = data.staffName ?? '';
    currentImageUrl.value = data.imageUrl;
  }

  Future<void> pickImage() async {
    try {
      isImageLoading.value = true;
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      _handleError('Error picking image', e);
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      final currentStaff = staffModel.value;

      if (currentStaff?.id == null) {
        throw Exception('Staff ID is missing');
      }

      final success = await _staffProfileService.updateStaffProfile(
        staffId: currentStaff!.id!,
        staffName: nameController.text.trim(),
        profileImage: selectedImage.value,
      );

      if (success) {
        // Get fresh data from Firestore
        DocumentSnapshot<Map<String, dynamic>> updatedDoc =
            await _firestore.collection("staffData").doc(currentStaff.id).get();

        if (updatedDoc.exists) {
          // Create updated staff model with new data
          StaffModel updatedStaff = StaffModel(
            id: currentStaff.id,
            staffName: updatedDoc.data()?['staffName'],
            staffPhone: currentStaff.staffPhone,
            staffPassword: currentStaff.staffPassword,
            staffEmail: currentStaff.staffEmail,
            userId: currentStaff.userId,
            imageUrl: updatedDoc.data()?['imageUrl'] ?? currentStaff.imageUrl,
          );

          // Update local state
          staffModel.value = updatedStaff;

          // Update SharedPreferences with fresh data
          await preferences.saveStaffDataPreference(updatedStaff);
        }

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.TOP,
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  void _handleError(String message, dynamic error) {
    print('❌ $message: $error');
    Get.snackbar(
      'Error',
      '$message: ${error.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
