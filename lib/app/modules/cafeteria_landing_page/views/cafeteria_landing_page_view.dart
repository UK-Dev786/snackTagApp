import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/widgets/custom_navbar.dart';
import '../controllers/cafeteria_landing_page_controller.dart';

class CafeteriaLandingPageView extends GetView<CafeteriaLandingPageController> {
  const CafeteriaLandingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => controller.screens[controller.selectedIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          selectedIndex: controller.selectedIndex.value,
          onItemTapped: controller.onItemTapped,
          imagePaths: controller.imagePaths,
        ),
      ),
    );
  }
}
