import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/authentication_service.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';

class StaffPhoneVerificationController extends GetxController {
  final isLoading = false.obs;
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthenticationService _authService = AuthenticationService();
final UserPreferences preferences = UserPreferences();
  // Handle login
  Future<void> staffLogin() async {

    isLoading.value = true;
    String staffPhone = phoneController.text.trim();
    String staffPassword = passwordController.text.trim();

    if (staffPhone.isEmpty || staffPassword.isEmpty) {
      showCustomSnack("Phone And Password Can't Be Empty");
      isLoading.value = false;
      return;
    }

    try {
      bool phoneExists = await _authService.isPhoneNumberExists(staffPhone);
      if (!phoneExists) {
        showCustomSnack("Phone Number Not Found. Please Enter the Correct Phone Number");
        isLoading.value = false;
        return;
      }

      // ✅ Wait for the login response and check if staff exists
      final staff = await _authService.staffLogin(staffPhone, staffPassword);
      if (staff != null) {
        Get.offAllNamed(Routes.STAFF_LANDING_PAGE); // Navigate on success
       preferences.saveStaffDataPreference(staff);
        phoneController.clear();
        passwordController.clear();
      } else {
        showCustomSnack("Phone number and password combination mismatch");
      }
    } catch (e) {
      showCustomSnack("Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
