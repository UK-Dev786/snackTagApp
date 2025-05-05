import 'package:get/get.dart';
import '../controllers/setting_parent_profile_controller.dart';

class SettingParentProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingParentProfileController>(
      () => SettingParentProfileController(),
    );
  }
}