import 'package:get/get.dart';

import '../controllers/staff_child_verification_controller.dart';

class StaffChildVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffChildVerificationController>(
      () => StaffChildVerificationController(),
    );
  }
}
