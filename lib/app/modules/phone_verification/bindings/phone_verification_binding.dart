import 'package:get/get.dart';

import '../controllers/phone_verification_controller.dart';

class PhoneVerificationBinding extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final String verificationId = arguments?['verificationId'] ?? '';
    final String phoneNumber = arguments?['phoneNumber'] ?? '';
    Get.lazyPut<PhoneVerificationController>(
      () => PhoneVerificationController(phoneNumber: phoneNumber, verificationId: verificationId),
    );
  }
}
