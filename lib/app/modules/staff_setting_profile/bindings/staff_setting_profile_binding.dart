import 'package:get/get.dart';
import '../controllers/staff_setting_profile_controller.dart';

class StaffSettingProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffSettingProfileController>(
      () => StaffSettingProfileController(),
    );
  }
}
