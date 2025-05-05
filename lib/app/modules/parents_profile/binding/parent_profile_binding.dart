import 'package:get/get.dart';
import 'package:snacktag/app/modules/parents_profile/controller/parent_profile_controller.dart';

class ParentsProfileBinding extends Bindings{
  @override
  void dependencies(){
    Get.lazyPut<ParentsProfileController>(
        ()=> ParentsProfileController()
    );

  }
}