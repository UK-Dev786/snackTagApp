import 'package:get/get.dart';

import '../controllers/staff_history_detail_controller.dart';

class StaffHistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffHistoryDetailController>(
      () => StaffHistoryDetailController(),
    );
  }
}
