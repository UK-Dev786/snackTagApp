import 'package:get/get.dart';

import '../controllers/parents_history_select_date_controller.dart';

class ParentsHistorySelectDateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsHistorySelectDateController>(
      () => ParentsHistorySelectDateController(),
    );
  }
}
