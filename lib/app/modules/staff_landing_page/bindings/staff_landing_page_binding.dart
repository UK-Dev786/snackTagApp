import 'package:get/get.dart';
import '../controllers/staff_landing_page_controller.dart';
import 'package:snacktag/app/modules/staff_history/controllers/staff_history_controller.dart';

class StaffLandingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StaffLandingPageController>(
      StaffLandingPageController(),
      permanent: true
    );
    
    // Also ensure StaffHistoryController is available
    if (!Get.isRegistered<StaffHistoryController>()) {
      Get.put<StaffHistoryController>(
        StaffHistoryController(),
        permanent: true
      );
    }
  }
}
