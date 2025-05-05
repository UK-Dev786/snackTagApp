import 'package:get/get.dart';

import '../controllers/cafeteria_child_verification_home_controller.dart';

class CafeteriaChildVerificationHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaChildVerificationHomeController>(
      () => CafeteriaChildVerificationHomeController(),
    );
  }
}
