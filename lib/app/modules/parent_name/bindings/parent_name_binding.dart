import 'package:get/get.dart';

import '../controllers/parent_name_controller.dart';

class ParentNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentNameController>(
      () => ParentNameController(),
    );
  }
}
