import 'package:get/get.dart';
import '../controllers/admin_setting_profile_controller.dart';

class AdminSettingProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminSettingProfileController>(
      () => AdminSettingProfileController(),
    );
  }
}