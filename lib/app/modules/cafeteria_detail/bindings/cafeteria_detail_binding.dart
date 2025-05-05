import 'package:get/get.dart';

import '../controllers/cafeteria_detail_controller.dart';

class CafeteriaDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaDetailController>(
      () => CafeteriaDetailController(),
    );
  }
}
