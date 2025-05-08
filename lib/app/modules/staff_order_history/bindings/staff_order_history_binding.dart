import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_history_list/controllers/staff_history_list_controller.dart';

import '../controllers/staff_order_history_controller.dart';

class StaffOrderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffOrderHistoryController>(
      () => StaffOrderHistoryController(),
    );
    
    // Also provide the StaffHistoryListController
    Get.lazyPut<StaffHistoryListController>(
      () => StaffHistoryListController(),
    );
  }
}