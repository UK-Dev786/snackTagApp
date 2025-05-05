import 'package:get/get.dart';

import '../controllers/cafeteria_phone_verification_controller.dart';

class CafeteriaPhoneVerificationBinding extends Bindings {
  @override
  void dependencies() {

    final arguments = Get.arguments as Map<String, dynamic>?;

    // Extract verificationId and phoneNumber from arguments
    final String verificationId = arguments?['verificationId'] ?? '';
    final String phoneNumber = arguments?['phoneNumber'] ?? '';

    // Pass the arguments to the controller
    Get.lazyPut<CafeteriaPhoneVerificationController>(
          () => CafeteriaPhoneVerificationController(
        verificationId: verificationId,
        phoneNumber: phoneNumber,
      ),
    );
    // Get.lazyPut<CafeteriaPhoneVerificationController>(
    //   () => CafeteriaPhoneVerificationController(),
    // );
  }
}
