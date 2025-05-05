import 'package:get/get.dart';

import '../controllers/cafeteria_home_settings_controller.dart';

class CafeteriaHomeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaHomeSettingsController>(
      () => CafeteriaHomeSettingsController(),
      fenix: true
    );
  }
}
