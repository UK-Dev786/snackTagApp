import 'package:get/get.dart';

import '../controllers/staff_history_calender_controller.dart';

class StaffHistoryCalenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffHistoryCalenderController>(
      () => StaffHistoryCalenderController(),
    );
  }
}
