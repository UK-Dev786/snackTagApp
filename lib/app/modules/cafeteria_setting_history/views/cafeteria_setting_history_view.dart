// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:snacktag/config/app_text_style.dart';
// import 'package:snacktag/widgets/custom_wallet_widget.dart';
// import 'package:snacktag/widgets/reuse_button.dart';
// import '../controllers/cafeteria_setting_history_controller.dart';

// class CafeteriaSettingHistoryView extends GetView<CafeteriaSettingHistoryController> {
//   const CafeteriaSettingHistoryView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: GetBuilder<CafeteriaSettingHistoryController>(
//           init: CafeteriaSettingHistoryController(),

//           builder: (context) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, top: 30),
//                   child: GestureDetector(
//                     onTap: () {
//                       // controller.updateSelectedIndex(0);
//                       Get.back();
//                     },
//                     child: Align(
//                       alignment: Alignment.topLeft,
//                       child: Container(
//                         height: 35,
//                         width: 35,
//                         margin: const EdgeInsets.only(top: 16), // Add some margin if needed
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               blurRadius: 4,
//                               spreadRadius: 2,
//                             ),
//                           ],
//                           color: Colors.white, // Background color for the container
//                         ),
//                         child: Center(
//                           child: Image.asset(
//                             "assets/icon/back.png",
//                             height: 15, // Set the height to 15
//                             width: 10, // Set the width to 15
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                     'History',
//                     style: AppTextStyles.MetropolisMedium.copyWith(
//                       fontSize: 18,
//                       color: const Color(0xFF434343),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Row with month/year and calendar icon
//                 // Padding(
//                 //   padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
//                 //   child: RichText(
//                 //     text: TextSpan(
//                 //       children: [
//                 //         TextSpan(
//                 //           text: 'July ',
//                 //           style: AppTextStyles.RobotoLight.copyWith(
//                 //             fontSize: 18,
//                 //             color: const Color(0xFF2E2E2E),
//                 //           ),
//                 //         ),
//                 //         TextSpan(
//                 //           text: '2024',
//                 //           style: AppTextStyles.RobotoBold.copyWith(
//                 //             fontSize: 18,
//                 //             color: const Color(0xFF2E2E2E),
//                 //           ),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),
//                 // ),

//                 // const SizedBox(width: 8),
//                 // Center(
//                 //   child: Image.asset(
//                 //     'assets/images/userimg.png', // Change to your image asset
//                 //     width: 125,
//                 //     height: 125,
//                 //   ),
//                 // ),

//                 // // First custom Row with text and image
//                 // Padding(
//                 //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 //   child: Row(
//                 //     mainAxisAlignment: MainAxisAlignment.center,
//                 //     children: [
//                 //       Text(
//                 //         'Student Photo',
//                 //         style: AppTextStyles.MetropolisMedium.copyWith(
//                 //           fontSize: 14,
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),

//                 // // Second custom Row with container, image, and texts
//                 // Padding(
//                 //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 //   child: Row(
//                 //     mainAxisAlignment: MainAxisAlignment.center,
//                 //     children: [
//                 //       Container(
//                 //         width: 166,
//                 //         height: 183,
//                 //         decoration: BoxDecoration(
//                 //           color: Colors.white.withOpacity(0.9), // Optional background color
//                 //           borderRadius: BorderRadius.circular(12),
//                 //         ),
//                 //         child: Column(
//                 //           children: [
//                 //             // Image taking 80% of the container height
//                 //             Image.asset(
//                 //               'assets/images/gra.png', // Change to your image asset
//                 //               width: double.infinity,
//                 //               height: 153, // 80% of container height
//                 //               fit: BoxFit.contain,
//                 //             ),
//                 //             // Bottom row with text and price
//                 //             const Spacer(),
//                 //             Row(
//                 //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //               children: [
//                 //                 Text(
//                 //                   'Chicken Gravy',
//                 //                   style: AppTextStyles.MetropolisMedium.copyWith(
//                 //                     fontSize: 16,
//                 //                   ),
//                 //                 ),
//                 //                 Text(
//                 //                   '\$25',
//                 //                   style: AppTextStyles.MetropolisMedium.copyWith(
//                 //                     fontSize: 16,
//                 //                   ),
//                 //                 ),
//                 //               ],
//                 //             ),
//                 //           ],
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),

//                 // ListView of WalletBalanceCards
//                 // ignore: prefer_const_constructors
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   child: const WalletBalanceCard(
//                     isEdit: false,
//                     walletDesc: 'Wallet Remaining Balance',
//                     price: '\$250',
//                     isShowScan: true,
//                     isNoImage: false,
//                     isPreparing: false,
//                     isDelivered: false,
//                     isStaff: true,
//                     isType: false,
//                     isDuration: false,
//                   ),
//                 ),

//                 CustomButton(text: 'Confirm', onPressed: () {}, isLoading: false.obs),
//                 const SizedBox(
//                   height: 16,
//                 )
//               ],
//             );
//           }
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_wallet_widget.dart';
import '../controllers/cafeteria_setting_history_controller.dart';

class CafeteriaSettingHistoryView
    extends GetView<CafeteriaSettingHistoryController> {
  const CafeteriaSettingHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Back Button and Title
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 35),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 35,
                    width: 35,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/icon/back.png",
                        height: 15,
                        width: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 100),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'History',
                    style: AppTextStyles.MetropolisMedium.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF434343),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Current Month and Year
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('MMMM ').format(DateTime.now()),
                      style: AppTextStyles.RobotoLight.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF2E2E2E),
                      ),
                    ),
                    Text(
                      DateTime.now().year.toString(),
                      style: AppTextStyles.RobotoBold.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF2E2E2E),
                      ),
                    ),
                  ],
                ),
                // Image.asset(
                //   'assets/icon/calendar.png',
                //   height: 20,
                //   width: 20,
                // ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Order History List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gradientEndColor,
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: AppTextStyles.PoppinsMedium.copyWith(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (controller.orderHistory.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No History Available',
                        style: AppTextStyles.PoppinsMedium.copyWith(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.orderHistory.length,
                itemBuilder: (context, index) {
                  final order = controller.orderHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(
                                0, 6), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Order Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white, // White border color
                                  width: 3, // Border width
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.25), // Shadow color with transparency
                                    blurRadius: 8, // Spread of the shadow
                                    offset: const Offset(
                                        0, 4), // Position of the shadow (x, y)
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: order.childImageUrl!.isNotEmpty
                                    ? Image.network(
                                        order.childImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 127,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                              Icons.error_outline_outlined,
                                              size: 20); //_buildPlaceholder();
                                        },
                                      )
                                    : Image.asset(
                                        // 'assets/images/userimg.png', // Replace with the actual image URL
                                        'assets/images/profile_emoji.png', // Replace with the actual image URL
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Order Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Order Name and Status
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.childName ?? 'Order',
                                        style: AppTextStyles.MetropolisMedium
                                            .copyWith(
                                          fontSize: 16,
                                          color: const Color(0xFF2E2E2E),
                                        ),
                                      ),
                                      // Container(
                                      //   padding: const EdgeInsets.symmetric(
                                      //     horizontal: 8,
                                      //     vertical: 4,
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     color: order.delivered == true
                                      //         ? AppColors.gradientEndColor.withOpacity(0.1)
                                      //         : order.startPreparation == true
                                      //             ? Colors.orange.withOpacity(0.1)
                                      //             : Colors.grey.withOpacity(0.1),
                                      //     borderRadius: BorderRadius.circular(12),
                                      //   ),
                                      //   child: Text(
                                      //     order.delivered == true
                                      //         ? 'Delivered'
                                      //         : order.startPreparation == true
                                      //             ? 'Preparing'
                                      //             : 'Pending',
                                      //     style: AppTextStyles.MetropolisRegular.copyWith(
                                      //       fontSize: 12,
                                      //       color: order.delivered == true
                                      //           ? AppColors.gradientEndColor
                                      //           : order.startPreparation == true
                                      //               ? Colors.orange
                                      //               : Colors.grey,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  // const SizedBox(height: 8),
                                  // Order Date and Price
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          // const Icon(
                                          //   Icons.access_time,
                                          //   size: 14,
                                          //   color: Color(0xFF8A8A8A),
                                          // ),
                                          // const SizedBox(width: 4),
                                          // Text(
                                          //    DateFormat('dd MMM yyyy').format(
                                          //     DateTime.parse(
                                          //       order.orderPreparationDate ?? DateTime.now().toIso8601String(),
                                          //     ),
                                          //   ),
                                          //   style: AppTextStyles.MetropolisRegular.copyWith(
                                          //     fontSize: 12,
                                          //     color: const Color(0xFF8A8A8A),
                                          //   ),
                                          // ),
                                          Text(
                                            order.schoolName!,
                                            style: AppTextStyles
                                                .MetropolisRegular.copyWith(
                                              fontSize: 12,
                                              color: const Color(0xFF8A8A8A),
                                            ),
                                          )
                                        ],
                                      ),
                                      // Price
                                      Text(
                                        'MX\$${order.selectedMealMenuData![0].mealPrice ?? '0.00'}',
                                        style: AppTextStyles.MetropolisBold
                                            .copyWith(
                                          fontSize: 16,
                                          color: const Color(0xFF2E2E2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 8),
                                  // Order Details
                                  Text(
                                    order.childSchoolID!,
                                    style: AppTextStyles.MetropolisRegular
                                        .copyWith(
                                      fontSize: 12,
                                      color: const Color(0xFF8A8A8A),
                                    ),
                                  )
                                  // Row(
                                  //   children: [
                                  //     Container(
                                  //       padding: const EdgeInsets.symmetric(
                                  //         horizontal: 8,
                                  //         vertical: 4,
                                  //       ),
                                  //       decoration: BoxDecoration(
                                  //         color: const Color(0xFFF5F5F5),
                                  //         borderRadius: BorderRadius.circular(12),
                                  //       ),
                                  //
                                  //     ),
                                  //     const SizedBox(width: 8),
                                  //
                                  //
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
