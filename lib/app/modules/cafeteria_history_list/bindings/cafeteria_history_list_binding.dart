import 'package:get/get.dart';

import '../controllers/cafeteria_history_list_controller.dart';

class CafeteriaHistoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaHistoryListController>(
      () => CafeteriaHistoryListController(),
    );
  }
}
