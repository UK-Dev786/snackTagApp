import 'package:get/get.dart';

import '../controllers/staff_home_settings_controller.dart';

class StaffHomeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffHomeSettingsController>(
      () => StaffHomeSettingsController(),
    );
  }
}
