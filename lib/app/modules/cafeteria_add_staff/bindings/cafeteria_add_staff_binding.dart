import 'package:get/get.dart';

import '../controllers/cafeteria_add_staff_controller.dart';

class CafeteriaAddStaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaAddStaffController>(
      () => CafeteriaAddStaffController(),
    );
  }
}
