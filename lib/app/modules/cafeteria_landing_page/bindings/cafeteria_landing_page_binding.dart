import 'package:get/get.dart';

import '../controllers/cafeteria_landing_page_controller.dart';

class CafeteriaLandingPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaLandingPageController>(
      () => CafeteriaLandingPageController(),
    );
  }
}
