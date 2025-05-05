import 'package:get/get.dart';
import 'package:snacktag/app/modules/parent_children_edit/controller/parent_children_edit_controller.dart';


class ParentsChildrenEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsChildrenEditController>(
          () => ParentsChildrenEditController(),
      fenix: true
    );
  }
}
