import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/parents_history_details/views/parents_history_details_view.dart';

import 'package:snacktag/app/modules/parents_history_select_date/views/parents_history_select_date_view.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/parent_header.dart';

import '../controllers/parents_history_controller.dart';

class ParentsHistoryView extends GetView<ParentsHistoryController> {
  const ParentsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Obx(() {
        //   if (controller.selectedIndex.value != 0) {
        //     return Padding(
        //       padding: const EdgeInsets.only(left: 20, top: 35),
        //       child: Align(
        //         alignment: Alignment.topLeft,
        //         child: GestureDetector(
        //           onTap: () {
        //             if (controller.selectedIndex.value == 1) {
        //               controller.updateSelectedIndex(0);
        //             }
        //           },
        //           child: Container(
        //             height: 35,
        //             width: 35,
        //             margin: const EdgeInsets.only(
        //                 top: 16), // Add some margin if needed
        //             decoration: BoxDecoration(
        //               shape: BoxShape.circle,
        //               boxShadow: [
        //                 BoxShadow(
        //                   color: Colors.grey.withOpacity(0.2),
        //                   blurRadius: 4,
        //                   spreadRadius: 2,
        //                 ),
        //               ],
        //               color: Colors.white, // Background color for the container
        //             ),
        //             child: Center(
        //               child: Image.asset(
        //                 "assets/icon/back.png",
        //                 height: 15, // Set the height to 15
        //                 width: 10, // Set the width to 15
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   } else {
        //     // You can return an empty container or SizedBox when the condition is not met
        //     return const SizedBox(
        //       height: 70,
        //     ); // No space is occupied if the condition is not met
        //   }
        // }),

        // const SizedBox(
        //   height: 8,
        // ),

        // // Settings Title
        // Obx(
        //   () => Text(
        //     controller.selectedIndex.value == 1
        //         ? 'History'
        //         : 'Upcoming', // Title text
        //     style: AppTextStyles.MetropolisMedium.copyWith(
        //       fontSize: 18,
        //       color: const Color(0xFF434343),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 32), // Spacing between title and list

        SizedBox(
          height: 360,
          child: ParentsHeader(),
        ),

        Expanded(
          child: Obx(
            () => IndexedStack(
              index: controller
                  .selectedIndex.value, // Bind the selected index to controller
              children: const [
                ParentsHistorySelectDateView(), // Second page: Date view
                ParentsHistoryDetailsView(), // Third page: Details view
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
