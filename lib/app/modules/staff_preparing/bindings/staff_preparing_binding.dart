import 'package:get/get.dart';
import '../controllers/staff_preparing_controller.dart';

class StaffPreparingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffOrderPreparingController>(
      () => StaffOrderPreparingController(),
    );
  }
}
