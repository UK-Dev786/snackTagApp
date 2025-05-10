import 'package:get/get.dart';

import '../controllers/children_details_controller.dart';

class ChildrenDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize the controller lazily to avoid build-time issues
    Get.lazyPut<ChildrenDetailsController>(
      () => ChildrenDetailsController(),
    );
  }
}
