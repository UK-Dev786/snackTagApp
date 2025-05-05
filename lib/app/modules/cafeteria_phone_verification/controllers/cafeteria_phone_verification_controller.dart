import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/services/authentication_service.dart';
import 'package:snacktag/services/user_service.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CafeteriaPhoneVerificationController extends GetxController {
    final FirebaseAuth _auth = FirebaseAuth.instance;  // Add this line

  final otpController = ''.obs; // Observable for OTP
  final isLoading = false.obs;
  final pin = ''.obs;

  final AuthenticationService _authService = AuthenticationService();
  final UserService _userService = UserService();

  final String verificationId;
  final String phoneNumber;

  CafeteriaPhoneVerificationController({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  void onInit() {
    super.onInit();
    // You can now use verificationId and phoneNumber in your controller
    print('Verification ID: $verificationId');
    print('Phone Number: $phoneNumber');
  }

  // Handle OTP verification
  Future<void> verifyOTP() async {
    if (otpController.value.isEmpty || otpController.value.length < 6) {
      showCustomSnack("Please enter a valid OTP");
      return;
    }

    try {
      isLoading.value = true;

      final result = await _authService.verifyOTP(verificationId, otpController.value);

      if (result.success) {
        final user = UserModel(
          phoneNumber: phoneNumber,
          role: 'cafeteriaAdmin',
          userAccountCreatedTime: DateTime.now(),
        );

        try {
          // First check if user exists and get their details
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .get();

          if (userDoc.exists) {
            // User exists, check for cafeteriaName
            final userData = userDoc.data();
            if (userData != null && userData['cafeteriaName'] != null) {
              // User has cafeteria details, go to landing page
              Get.offAllNamed(Routes.CAFETERIA_LANDING_PAGE);
            } else {
              // User exists but no cafeteria details, go to details page
              Get.toNamed(Routes.CAFETERIA_DETAIL);
            }
          } else {
            // New user, create user and go to details page
            await _userService.createUser(user);
            Get.toNamed(Routes.CAFETERIA_DETAIL);
          }
        } catch (e) {
          print("Error in user creation/verification: $e");
          showCustomSnack("Error creating user profile. Please try again.");
        }
      } else {
        showCustomSnack(result.message);
      }
    } catch (e) {
      print("Error in OTP verification: $e");
      showCustomSnack("Verification failed. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }
}
