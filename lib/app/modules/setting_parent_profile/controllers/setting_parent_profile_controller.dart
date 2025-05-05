import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/parents/parent_profile_update_service.dart';

class SettingParentProfileController extends GetxController {
  final ParentProfileUpdateService _profileService = ParentProfileUpdateService();
  
  final nameController = TextEditingController();
  final isLoading = false.obs;
  final isImageLoading = false.obs;
  final userProfile = Rxn<UserModel>();
  final selectedImage = Rxn<File>();
  final currentImageUrl = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      isImageLoading.value = true;
      final profile = await _profileService.getCurrentUserProfile();
      if (profile != null) {
        userProfile.value = profile;
        nameController.text = profile.parentsName ?? '';
        currentImageUrl.value = profile.parentsPic;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isImageLoading.value = false;

    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      isImageLoading.value = true;
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      if (selectedImage.value != null) {
        isImageLoading.value = true;
      }
      
      final success = await _profileService.updateParentProfile(
        parentName: nameController.text.trim(),
        newImageFile: selectedImage.value,
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchUserProfile(); // Refresh profile data
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isImageLoading.value = false;
    }
  }
}
