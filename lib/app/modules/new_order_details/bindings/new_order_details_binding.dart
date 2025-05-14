import 'package:get/get.dart';
import '../controllers/new_order_details_controller.dart';

class NewOrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewOrderDetailsController>(
      () => NewOrderDetailsController(),
    );
  }
}
