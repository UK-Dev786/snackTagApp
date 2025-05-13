import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_upcoming_detail/controller/cafeteria_upcoming_detail_controller.dart';
import 'package:snacktag/config/app_text_style.dart';

import 'package:intl/intl.dart';

class CafeteriaUpcomingDetailsView extends StatelessWidget {
  const CafeteriaUpcomingDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    // final historyController = Get.find<StaffHistoryController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: GetBuilder<CafeteriaUpcomingDetailsController>(
                init: CafeteriaUpcomingDetailsController(),
                builder: (controller) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 30),
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 30),
                        child: GestureDetector(
                          onTap: () {
                            // controller.updateSelectedIndex(0);
                            Get.back();
                          },
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: 35,
                              width: 35,
                              margin: const EdgeInsets.only(
                                  top: 16), // Add some margin if needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                  ),
                                ],
                                color: Colors
                                    .white, // Background color for the container
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/icon/back.png",
                                  height: 15, // Set the height to 15
                                  width: 10, // Set the width to 15
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Details',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 18,
                            color: const Color(0xFF434343),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Month and Year
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    DateFormat('MMMM ').format(DateTime.now()),
                                style: AppTextStyles.RobotoLight.copyWith(
                                  fontSize: 18,
                                  color: const Color(0xFF2E2E2E),
                                ),
                              ),
                              TextSpan(
                                text: '${DateTime.now().year}',
                                style: AppTextStyles.RobotoBold.copyWith(
                                  fontSize: 18,
                                  color: const Color(0xFF2E2E2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // List of Orders
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (controller.errorMessage.value.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 48,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyles.PoppinsMedium.copyWith(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (controller.childrenList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No children found for this meal',
                                  style: AppTextStyles.PoppinsMedium.copyWith(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: controller.childrenList.length,
                          separatorBuilder: (context, index) {
                            return Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            );
                          },
                          itemBuilder: (context, index) {
                            final child = controller.childrenList[index];
                            return Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: child.childImageUrl != null &&
                                                  child
                                                      .childImageUrl!.isNotEmpty
                                              ? Image.network(
                                                  child.childImageUrl!,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/profile_emoji.png',
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  'assets/images/profile_emoji.png',
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              child.childName ?? "N/A",
                                              style: AppTextStyles
                                                  .MetropolisMedium.copyWith(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          child.schoolName ?? "N/A",
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            fontSize: 12,
                                            color: const Color(0xFF858585),
                                          ),
                                        ),
                                        Text(
                                          child.childSchoolID ?? "N/A",
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            fontSize: 12,
                                            color: const Color(0xFF858585),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   body: SingleChildScrollView(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.only(left: 20),
    //           child: Align(
    //             alignment: Alignment.topLeft,
    //             child: GestureDetector(
    //               onTap: () {
    //                 historyController.updateSelectedIndex(0);
    //               },
    //               child: Container(
    //                 height: 35,
    //                 width: 35,
    //                 margin: const EdgeInsets.only(
    //                     top: 16), // Add some margin if needed
    //                 decoration: BoxDecoration(
    //                   shape: BoxShape.circle,
    //                   boxShadow: [
    //                     BoxShadow(
    //                       color: Colors.grey.withOpacity(0.2),
    //                       blurRadius: 4,
    //                       spreadRadius: 2,
    //                     ),
    //                   ],
    //                   color: Colors.white, // Background color for the container
    //                 ),
    //                 child: Center(
    //                   child: Image.asset(
    //                     "assets/icon/back.png",
    //                     height: 15, // Set the height to 15
    //                     width: 10, // Set the width to 15
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //
    //         Center(
    //           child: Text(
    //             'History',
    //             style: AppTextStyles.MetropolisBold.copyWith(
    //               fontSize: 18,
    //               color: const Color(0xFF434343),
    //             ),
    //           ),
    //         ),
    //
    //         // Row with month/year and calendar icon
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
    //           child: RichText(
    //             text: TextSpan(
    //               children: [
    //                 TextSpan(
    //                   text: '20,July ',
    //                   style: AppTextStyles.RobotoLight.copyWith(
    //                     fontSize: 18,
    //                     color: const Color(0xFF2E2E2E),
    //                   ),
    //                 ),
    //                 TextSpan(
    //                   text: '2024',
    //                   style: AppTextStyles.RobotoBold.copyWith(
    //                     fontSize: 18,
    //                     color: const Color(0xFF2E2E2E),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //
    //         const SizedBox(width: 8),
    //         Center(
    //           child: Image.asset(
    //             'assets/images/userimg.png', // Change to your image asset
    //             width: 125,
    //             height: 125,
    //           ),
    //         ),
    //
    //         // First custom Row with text and image
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Text(
    //                 'Student Photo',
    //                 style: AppTextStyles.MetropolisMedium.copyWith(
    //                   fontSize: 14,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //
    //         // Second custom Row with container, image, and texts
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Container(
    //                 width: 166,
    //                 height: 183,
    //                 decoration: BoxDecoration(
    //                   color: Colors.white
    //                       .withOpacity(0.9), // Optional background color
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 child: Column(
    //                   children: [
    //                     // Image taking 80% of the container height
    //                     Image.asset(
    //                       'assets/images/gra.png', // Change to your image asset
    //                       width: double.infinity,
    //                       height: 153, // 80% of container height
    //                       fit: BoxFit.contain,
    //                     ),
    //                     // Bottom row with text and price
    //                     const Spacer(),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           'Chicken Gravy',
    //                           style: AppTextStyles.MetropolisMedium.copyWith(
    //                             fontSize: 16,
    //                           ),
    //                         ),
    //                         Text(
    //                           '\$25',
    //                           style: AppTextStyles.MetropolisMedium.copyWith(
    //                             fontSize: 16,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //
    //         // ListView of WalletBalanceCards
    //         // ignore: prefer_const_constructors
    //         Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    //           child: const WalletBalanceCard(
    //             isEdit: false,
    //             walletDesc: 'Wallet Remaining Balance',
    //             price: '\$250',
    //             isShowScan: true,
    //             isNoImage: true,
    //             isPreparing: false,
    //             isDelivered: false,
    //             isStaff: false,
    //             isType: false,
    //             isDuration: false,
    //           ),
    //         ),
    //
    //         CustomButton(
    //             text: 'Confirm', onPressed: () {}, isLoading: false.obs),
    //         SizedBox(
    //           height: 16,
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
