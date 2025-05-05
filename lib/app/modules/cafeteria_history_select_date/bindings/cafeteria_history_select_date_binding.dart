import 'package:get/get.dart';

import '../controllers/cafeteria_history_select_date_controller.dart';

class CafeteriaHistorySelectDateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaHistorySelectDateController>(
      () => CafeteriaHistorySelectDateController(),
    );
  }
}
