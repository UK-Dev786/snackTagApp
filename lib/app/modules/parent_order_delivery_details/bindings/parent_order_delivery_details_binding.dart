import 'package:get/get.dart';
import '../controllers/parent_order_delivery_details_controller.dart';

class ParentOrderDeliveryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentOrderDeliveryDetailsController>(
      () => ParentOrderDeliveryDetailsController(),
    );
  }
}
