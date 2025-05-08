import 'package:get/get.dart';
import '../controllers/staff_order_details_controller.dart';

class StaffOrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffOrderDetailsController>(
      () => StaffOrderDetailsController(),
    );
  }
}
