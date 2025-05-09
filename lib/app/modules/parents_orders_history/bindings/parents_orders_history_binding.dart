import 'package:get/get.dart';

import '../controllers/parents_orders_history_controller.dart';

class ParentsOrdersHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsOrdersHistoryController>(
      () => ParentsOrdersHistoryController(),
    );
  }
}
