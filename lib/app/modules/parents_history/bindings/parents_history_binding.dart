import 'package:get/get.dart';

import '../controllers/parents_history_controller.dart';

class ParentsHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsHistoryController>(
      () => ParentsHistoryController(),
    );
  }
}
