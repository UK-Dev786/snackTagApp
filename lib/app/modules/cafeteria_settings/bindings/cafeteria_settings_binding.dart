import 'package:get/get.dart';

import '../controllers/cafeteria_settings_controller.dart';

class CafeteriaSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaSettingsController>(
      () => CafeteriaSettingsController(),
    );
  }
}
