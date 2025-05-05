import 'package:get/get.dart';

import '../controllers/staff_history_list_controller.dart';

class StaffHistoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffHistoryListController>(
      () => StaffHistoryListController(),
    );
  }
}
