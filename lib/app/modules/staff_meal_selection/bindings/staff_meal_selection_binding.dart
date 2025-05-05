import 'package:get/get.dart';

import '../controllers/staff_meal_selection_controller.dart';

class StaffMealSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffMealSelectionController>(
      () => StaffMealSelectionController(),
      fenix: true
    );
    // Get.put(StaffMealSelectionController()); // Force initialization

  }
}
