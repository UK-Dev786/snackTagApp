import 'package:get/get.dart';

import '../controllers/cafeteria_meal_details_controller.dart';

class CafeteriaMealDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaMealDetailsController>(
      () => CafeteriaMealDetailsController(),
    );
  }
}
