import 'package:get/get.dart';

import '../controllers/cafeteria_history_controller.dart';

class CafeteriaHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaHistoryController>(
      () => CafeteriaHistoryController(),
    );
  }
}
