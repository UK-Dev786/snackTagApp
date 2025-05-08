import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/staff_services/cafeteria_child_verification_service.dart';

class CafeteriaChildVerificationController extends GetxController {
  final CafeteriaChildVerificationService cafeteriaChildVerificationService =
      CafeteriaChildVerificationService();
  final schoolIdController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isValid = false.obs;
  var childrenList = <ParentsAddChildren>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Add listener to validate on every change
    schoolIdController.addListener(validateSchoolId);
  }

  Future<bool> fetchCafateriaChildren() async {
    try {
      isLoading.value = true;

      if (!isValid.value) {
        Get.snackbar(
          'Validation Error',
          errorMessage.value,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }

      List<ParentsAddChildren> children =
          await cafeteriaChildVerificationService
              .fetchChildrenBySchoolId(schoolIdController.text.trim());

      if (children.isEmpty) {
        Get.snackbar(
          'Not Found',
          'No children found with this School ID',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
        );
        return false;
      }

      childrenList.assignAll(children);
      print("children data is  $children");

      // Show success message
      Get.snackbar(
        'Success',
        'Child verified successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

      return true;
    } catch (e) {
      print("Error fetching children: $e");
      Get.snackbar(
        'Error',
        'Failed to verify child. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    } finally {
      isLoading.value = false;
      update(['cafateriaHistorySelectDataId']);
    }
  }

  @override
  void onClose() {
    schoolIdController.removeListener(validateSchoolId);
    schoolIdController.dispose();
    super.onClose();
  }

  void validateSchoolId() {
    String value = schoolIdController.text.trim();

    if (value.isEmpty) {
      errorMessage.value = 'Child School ID is required';
      isValid.value = false;
    } else if (value.length < 3) {
      errorMessage.value = 'School ID must be at least 3 characters';
      isValid.value = false;
    } else if (value.length > 20) {
      errorMessage.value = 'School ID cannot exceed 20 characters';
      isValid.value = false;
    } else if (!RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(value)) {
      errorMessage.value =
          'Only letters, numbers, hyphens and underscores allowed';
      isValid.value = false;
    } else {
      errorMessage.value = '';
      isValid.value = true;
    }
  }

  void verifyChildId() {
    String value = schoolIdController.text.trim();
    
    validateSchoolId();

    if (!isValid.value) {
      Get.snackbar(
        'Validation Error',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
      return;
    }

    print('Verifying Child School ID: $value');
    // Proceed with verification logic here
  }
}
