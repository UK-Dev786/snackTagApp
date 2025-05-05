import 'package:get/get.dart';
import '../controllers/child_verification_upload_info_controller.dart';

class ChildVerificationUploadInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChildVerificationUploadInfoController>(
      ChildVerificationUploadInfoController(),
      permanent: false,
    );
  }
}
