import 'package:get/get.dart';

import '../controllers/parents_add_wallet_controller.dart';

class ParentsAddWalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentsAddWalletController>(
      () => ParentsAddWalletController(),
    );
  }
}
