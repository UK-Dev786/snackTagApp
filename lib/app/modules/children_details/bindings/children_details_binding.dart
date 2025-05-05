import 'package:get/get.dart';

import '../controllers/children_details_controller.dart';

class ChildrenDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChildrenDetailsController>(
      () => ChildrenDetailsController(),
    );
  }
}
