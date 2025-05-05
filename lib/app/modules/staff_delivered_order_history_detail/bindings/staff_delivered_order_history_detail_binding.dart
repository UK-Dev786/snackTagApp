import 'package:get/get.dart';
import '../controller/staff_delivered_order_history_controller.dart';

class StaffDeliveredOrderHistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffDeliveredOderHistoryDetailsController>(
      () => StaffDeliveredOderHistoryDetailsController(),
    );
  }
}