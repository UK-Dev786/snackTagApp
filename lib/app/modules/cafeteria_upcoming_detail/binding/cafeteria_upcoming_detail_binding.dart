import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_upcoming_detail/controller/cafeteria_upcoming_detail_controller.dart';

class CafeteriaUpcomingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CafeteriaUpcomingDetailsController>(
          () => CafeteriaUpcomingDetailsController(),
    );
  }
}
