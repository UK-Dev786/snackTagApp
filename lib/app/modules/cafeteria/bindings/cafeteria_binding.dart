import 'package:get/get.dart';

import '../controllers/cafeteria_controller.dart';

class CafeteriaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaController>(
      () => CafeteriaController(),
    );
  }
}
