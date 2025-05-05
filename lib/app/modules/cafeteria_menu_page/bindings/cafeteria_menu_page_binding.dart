import 'package:get/get.dart';

import '../controllers/cafeteria_menu_page_controller.dart';

class CafeteriaMenuPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaMenuPageController>(
      () => CafeteriaMenuPageController(),
      fenix: true
    );
  }
}
