import 'package:get/get.dart';

import '../controllers/cafeteria_child_verification_controller.dart';

class CafeteriaChildVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CafeteriaChildVerificationController());
  }
}
