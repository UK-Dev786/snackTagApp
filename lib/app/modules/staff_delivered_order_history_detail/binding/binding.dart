import 'package:get/get.dart';
import '../controller/staff_delivered_order_history_controller.dart';

class StaffDeliveredOrderHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StaffDeliveredOderHistoryDetailsController>(
      StaffDeliveredOderHistoryDetailsController(),
      permanent: true,  // Make the controller permanent
    );
  }
}
