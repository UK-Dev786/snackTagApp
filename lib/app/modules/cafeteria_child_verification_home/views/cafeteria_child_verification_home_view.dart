import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_child_verification/views/cafeteria_child_verification_view.dart';
import 'package:snacktag/app/modules/child_verification_upload_info/views/child_verification_upload_info_view.dart';

import '../controllers/cafeteria_child_verification_home_controller.dart';

class CafeteriaChildVerificationHomeView
    extends GetView<CafeteriaChildVerificationHomeController> {
  const CafeteriaChildVerificationHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Obx(
            () => IndexedStack(
              index: controller
                  .selectedIndex.value, // Bind the selected index to controller
              children:const [
                // First child
                 CafeteriaChildVerificationView(),

                // Third child
                // ChildVerificationUploadInfoView(),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
