import 'package:get/get.dart';

import '../controllers/cafeteria_phone_authenication_controller.dart';

class CafeteriaPhoneAuthenicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaPhoneAuthenicationController>(
      () => CafeteriaPhoneAuthenicationController(),
    );
  }
}
