import 'package:get/get.dart';
import '../controller/parent_upcoming_order_detail_controller.dart';

class ParentUpcomingOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentUpcomingOrderDetailController>(
      () => ParentUpcomingOrderDetailController(),
    );
  }
}