import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/services/authentication_service.dart';
import 'package:snacktag/services/parent_authentication-service.dart';
// import 'package:snacktag/app/routes/app_routes.dart';t';

import '../../../../widgets/custom_snackbar.dart';

class PhoneAuthenticationController extends GetxController {
  final phoneController = TextEditingController();
  final isLoading = false.obs;

  final ParentAuthenticationService _authService = ParentAuthenticationService();

  // Validate phone number
  bool validatePhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$'); // International format
    if (phoneNumber.isEmpty) {
      showCustomSnack("Phone number can't be empty");
      return false;
    } else if (!phoneRegex.hasMatch(phoneNumber)) {
      showCustomSnack("Enter a valid phone number");
      return false;
    }
    return true;
  }

  // Handle phone number authentication
  Future<void> authenticatePhoneNumber() async {
    final phoneNumber = phoneController.text.trim();

    log("Phone number: $phoneNumber");

    if (!validatePhoneNumber(phoneNumber)) return;

    isLoading.value = true;

    // Call the service and wait for the result
    final result = await _authService.authenticatePhoneNumber(phoneNumber);

    isLoading.value = false;

    // Handle result
    if (result.success) {
      if (result.verificationId != null) {
        // Navigate to OTP verification screen
        print('Auth Test ✅vId: ${result.verificationId}');
        print('Auth Test ✅phone: ${phoneNumber}');
        Get.toNamed(Routes.PHONE_VERIFICATION, arguments: {
          'verificationId': result.verificationId,
          'phoneNumber': phoneNumber,
        });
      } else {
        // Navigate to the home screen if no verificationId (auto-verification)
        showCustomSnack(result.message);
      }
    } else {
      showCustomSnack(result.message);
    }
  }
}
