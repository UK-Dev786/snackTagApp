import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_phone_verification/controllers/staff_phone_verification_controller.dart';

class StaffPhoneVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffPhoneVerificationController>(() => StaffPhoneVerificationController());
  }
}
