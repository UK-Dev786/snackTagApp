import 'package:get/get.dart';
import '../controllers/cafe_owner_order_delivery_details_controller.dart';

class CafeOwnerOrderDeliveryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeOwnerOrderDeliveryDetailsController>(
      () => CafeOwnerOrderDeliveryDetailsController(),
    );
  }
}
