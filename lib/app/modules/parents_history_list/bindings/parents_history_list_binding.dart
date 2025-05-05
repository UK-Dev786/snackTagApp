import 'package:get/get.dart';

import '../controllers/parents_history_list_controller.dart';

class ParentsHistoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsHistoryListController>(
      () => ParentsHistoryListController(),
    );
  }
}
