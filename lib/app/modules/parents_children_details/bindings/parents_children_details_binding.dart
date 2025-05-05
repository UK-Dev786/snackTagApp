import 'package:get/get.dart';

import '../controllers/parents_children_details_controller.dart';

class ParentsChildrenDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsChildrenDetailsController>(
      () => ParentsChildrenDetailsController(),
      fenix: true,
    );
  }
}
