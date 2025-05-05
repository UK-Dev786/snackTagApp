import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/admin/admin_profile_update_service.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController
  final AdminProfileUpdateService _profileService = AdminProfileUpdateService();

  final nameController = TextEditingController();
  final isLoading = false.obs;
  final isImageLoading = false.obs;
  final userProfile = Rxn<UserModel>();
  final selectedImage = Rxn<File>();
  final currentImageUrl = RxnString();
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchAdminProfile();

  }
  Future<void> fetchAdminProfile() async {
    try {
      isLoading.value = true;
      final profile = await _profileService.getCurrentUserProfile();
      if (profile != null) {
        userProfile.value = profile;
        nameController.text = profile.cafeteriaName ?? '';
        currentImageUrl.value = profile.cafeteriaLogo;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch profile: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
