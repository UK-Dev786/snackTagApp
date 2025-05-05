import 'package:get/get.dart';
import '../controllers/cafeteria_history_details_controller.dart';

class CafeteriaHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaHistoryDetailsController>(
      () => CafeteriaHistoryDetailsController(),
    );
  }
}
