import 'package:get/get.dart';
import '../controllers/staff_history_controller.dart';

class StaffHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StaffHistoryController>(
      StaffHistoryController(),
      permanent: true,  // Make the controller permanent
    );
  }
}
