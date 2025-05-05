import 'package:get/get.dart';
import '../controllers/cafeteria_setting_history_controller.dart';

class CafeteriaSettingHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaSettingHistoryController>(
      () => CafeteriaSettingHistoryController(),
      fenix: true,
    );
  }
}