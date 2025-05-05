import 'package:get/get.dart';

import '../controllers/cafeteria_staff_list_controller.dart';

class CafeteriaStaffListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaStaffListController>(
      () => CafeteriaStaffListController(),
    );
  }
}
