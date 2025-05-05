import 'package:get/get.dart';

import '../controllers/phone_authentication_controller.dart';

class PhoneAuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneAuthenticationController>(
      () => PhoneAuthenticationController(),
    );
  }
}
