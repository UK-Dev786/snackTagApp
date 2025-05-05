import 'package:get/get.dart';

import '../controllers/parents_history_details_controller.dart';

class ParentsHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsHistoryDetailsController>(
      () => ParentsHistoryDetailsController(),
    );
  }
}
