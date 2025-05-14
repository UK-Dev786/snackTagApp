import 'package:get/get.dart';
import '../controllers/parent_order_preparation_details_controller.dart';

class ParentOrderPreparationDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentOrderPreparationDetailsController>(
      () => ParentOrderPreparationDetailsController(),
    );
  }
}
