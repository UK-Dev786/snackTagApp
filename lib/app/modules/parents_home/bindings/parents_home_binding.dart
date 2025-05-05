import 'package:get/get.dart';

import '../controllers/parents_home_controller.dart';

class ParentsHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsHomeController>(
      () => ParentsHomeController(),
    );
  }
}
