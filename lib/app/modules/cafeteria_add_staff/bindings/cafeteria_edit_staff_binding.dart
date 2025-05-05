import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_add_staff/controllers/cafeteria_edit_staff_controller.dart';

import '../controllers/cafeteria_add_staff_controller.dart';

class CafeteriaEditStaffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaEditStaffController>(
          () => CafeteriaEditStaffController(),
    );
  }
}
// +923349152407