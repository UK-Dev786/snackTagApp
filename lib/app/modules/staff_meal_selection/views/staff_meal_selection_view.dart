// import 'package:flutter/material.dart';
// import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
//
// import 'package:get/get.dart';
//
// import 'package:snacktag/config/app_colors.dart';
// import 'package:snacktag/config/app_text_style.dart';
// import 'package:snacktag/widgets/custom_textfeild.dart';
//
// import '../controllers/staff_meal_selection_controller.dart';
//
// class StaffMealSelectionView extends GetView<StaffMealSelectionController> {
//   const StaffMealSelectionView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final textController = TextEditingController();
//     return Scaffold(
//       backgroundColor: Colors.white, // Set the background color to white
//
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     height: 70,
//                   ),
//
//                   // Settings Title
//                   Text(
//                     'SELECT MEAL', // Title text
//                     style: AppTextStyles.MetropolisMedium.copyWith(
//                       fontSize: 18,
//                       color: const Color(0xFF434343),
//                     ),
//                   ),
//                   const SizedBox(height: 42), // Spacing between title and list
//                   _buildSearchField(textController),
//                   const SizedBox(height: 30),
//                   _buildText(),
//                   _buildMenuList(),
//                   const SizedBox(height: 12),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Search TextField Widget (moved slightly down)
//   Widget _buildSearchField(TextEditingController textController) {
//     return TextFieldWidget(
//       text: 'Search Meal',
//       textController: textController,
//       path: 'assets/icon/search.png',
//       isBGChangeColor: true,
//       height: 40,
//       isSuffixBG: true,
//       onChanged: (value) {},
//     );
//   }
//
//   // "Congratulations" text in the center
//   Widget _buildText() {
//     return Center(
//       child: Text(
//         'Collage/School Name', // Replace with dynamic text
//         style: AppTextStyles.PoppinsBold.copyWith(
//           fontSize: 14,
//           color: AppColors.blackColor,
//         ),
//       ),
//     );
//   }
//
// // List of Menu Items (GridView with Image, Name, Price)
//   Widget _buildMenuList() {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3, // 3 items per row
//         mainAxisSpacing: 16, // Spacing between rows
//         crossAxisSpacing: 8, // Spacing between columns
//         childAspectRatio: 100 / 170, // Aspect ratio for the containers
//       ),
//       itemCount: 6, // Total number of items
//       itemBuilder: (context, index) {
//         return _buildMenuItem(index);
//       },
//     );
//   }
//
// // Menu item container (GridView item)
//   Widget _buildMenuItem(int index) {
//     final _controller = ValueNotifier<bool>(true);
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start, // Ensures left alignment
//           children: [
//             // Image Placeholder
//             Image.asset(
//               // Use modulo operator to group indices
//               index % 3 == 0 || index % 3 == 3
//                   ? 'assets/images/gravy.png' // Images for index 0 and index 3
//                   : index % 3 == 1 || index % 3 == 4
//                       ? 'assets/images/pepper.png' // Images for index 1 and index 4
//                       : index % 3 == 2 || index % 3 == 5
//                           ? 'assets/images/roast.png' // Images for index 2 and index 5
//                           : 'assets/images/gravy.png', // Replace with actual image path
//               width: double.infinity, // Image takes the full width
//
//               fit: BoxFit.cover,
//             ),
//             // Menu Item Name and Price
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                   vertical: 4.0), // Add padding around text
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start, // Align text to the left
//                 children: [
//                   // Menu Item Name
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         // Use modulo operator to group indices
//                         index % 3 == 0 || index % 3 == 3
//                             ? 'Chicken Gravy' // Images for index 0 and index 3
//                             : index % 3 == 1 || index % 3 == 4
//                                 ? 'Pepper Chicken' // Images for index 1 and index 4
//                                 : index % 3 == 2 || index % 3 == 5
//                                     ? 'Roast Chicken' // Images for index 2 and index 5
//                                     : 'Roast Chicken', // Replace with dynamic name
//                         style: AppTextStyles.MetropolisMedium.copyWith(
//                           fontSize: 10,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Image.asset(
//                         'assets/icon/delete.png', // Replace with actual icon
//                         width: 15,
//                         height: 15,
//                       )
//                     ],
//                   ),
//                   // Menu Item Price
//                   const SizedBox(
//                       height: 4), // Add spacing between name and price
//                   Text(
//                     // Use modulo operator to group indices
//                     index % 3 == 0 || index % 3 == 3
//                         ? '\$25' // Images for index 0 and index 3
//                         : index % 3 == 1 || index % 3 == 4
//                             ? '\$45' // Images for index 1 and index 4
//                             : index % 3 == 2 || index % 3 == 5
//                                 ? '\$25' // Images for index 2 and index 5
//                                 : '\$25', // Default image, // Replace with dynamic price
//                     style: AppTextStyles.MetropolisMedium.copyWith(
//                       fontSize: 10,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Row for Switch and Add Button
//             Padding(
//               padding: const EdgeInsets.only(), // Add padding for the row
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment
//                     .spaceBetween, // Space between switch and Add button
//                 children: [
//                   AdvancedSwitch(
//                     controller: _controller,
//                     activeColor: Colors.green,
//                     height: 12,
//                     width: 25,
//                   ),
//                   // Add Button text
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white, // Background color (optional)
//                       border: Border.all(
//                         color: const Color(0xFFEFEFEF), // Border color
//                         width: 1, // Border width
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF707070)
//                               .withOpacity(0.1), // Shadow color with opacity
//                           spreadRadius: 1, // Spread radius of shadow
//                           blurRadius: 1, // Blur radius of shadow
//                           offset: const Offset(0,
//                               1), // Only vertical offset (bottom side shadow)
//                         ),
//                       ],
//
//                       borderRadius: BorderRadius.circular(
//                           32), // Rounded corners (optional)
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 3), // Inner padding
//                     child: Text(
//                       'Edit', // Static "Add" text
//                       style: AppTextStyles.PoppinsRegular.copyWith(
//                         fontSize: 7,
//                         color: const Color(0xFFFFAA00),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/staff_meal_selection/controllers/staff_meal_selection_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/widgets/Custom_search_textfield.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';

import 'package:snacktag/widgets/reuse_button.dart';

class StaffMealSelectionView extends GetView<StaffMealSelectionController> {
  const StaffMealSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          // color: Colors.red,
          child: Stack(
            children: [
              ListView(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 70,
                        ),

                        Image.asset(
                          AppImages.authImg,
                          width: 85,
                          height: 95,
                        ),

                        SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.8, // 80% of screen width
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Make row take minimum space needed
                              children: [
                                Image.asset(
                                  'assets/images/school_building_unfilled.png',
                                  width: 30, // Reduced from 40
                                  height: 30, // Reduced from 40
                                ),
                                const SizedBox(
                                  width: 10, // Reduced from 20
                                ),
                                Flexible(
                                  child: Obx(() => Text(
                                        controller.schoolName.value,
                                        style: AppTextStyles.MetropolisMedium
                                            .copyWith(
                                          fontSize: 16, // Reduced from 18
                                          color: const Color(0xFF434343),
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle text overflow
                                        maxLines: 1, // Ensure single line
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // /Users/user/Documents/Projects/Buzzware tech/snackTagApp/merged/assets/images/school_building_unfilled.png
                        // const SizedBox(
                        //     height: 42), // Spacing between title and list
                        // _buildSearchField(controller.searchTextController),
                        // const SizedBox(height: 30),
                        // _buildText(),
                        const SizedBox(height: 32),

                        _buildMenuList(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  // _buildBottomFixedButton(),
                ],
              ),
              // Positioned(
              //   bottom: 10,
              //   left: 0,
              //   right: 0,
              //   child: _buildBottomFixedButton(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Search TextField Widget (moved slightly down)
  Widget _buildSearchField(TextEditingController textController) {
    // return TextFieldWidget(
    //   text: 'Search Meal',
    //   textController: textController,
    //   path: 'assets/icon/search.png',
    //   isBGChangeColor: true,
    //   height: 40,
    //   isSuffixBG: true,
    //   onChanged: (value) => controller.updateSearchText(value),
    // );
    return SearchTextFieldWidget(
      hintText: 'Search Meal',
      textController: textController,
      onChanged: (value) => controller.updateSearchText(value),
    );
  }

  // "Congratulations" text in the center
  Widget _buildText() {
    return Center(
      child: Text(
        'Collage/School Name', // Replace with dynamic text
        style: AppTextStyles.PoppinsBold.copyWith(
          fontSize: 14,
          color: AppColors.blackColor,
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : controller.isDataFound.value == true
            ? Text(
                'Data Not Found', // Replace with dynamic text
                style: AppTextStyles.PoppinsBold.copyWith(
                  fontSize: 14,
                  color: AppColors.blackColor,
                ),
              )
            : controller.meals.value.isEmpty
                ? Text(
                    'Meal Not Available', // Replace with dynamic text
                    style: AppTextStyles.PoppinsBold.copyWith(
                      fontSize: 14,
                      color: AppColors.blackColor,
                    ),
                  )
                :
                // GridView.builder(
                //             shrinkWrap: true,
                //             physics: const NeverScrollableScrollPhysics(),
                //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //               crossAxisCount: 3,
                //               mainAxisSpacing: 16,
                //               crossAxisSpacing: 8,
                //               childAspectRatio: 100 / 170,
                //             ),
                //             itemCount: controller.searchText.value.isEmpty
                //                 ? controller.meals.length
                //                 : controller.filteredMeals.length,
                //             itemBuilder: (context, index) {
                //               return _buildMenuItem(
                //                 controller.searchText.value.isEmpty
                //                     ? controller.meals[index]
                //                     : controller.filteredMeals[index],
                //               );
                //             },
                //           )
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 8,
                      childAspectRatio: 100 / 170,
                    ),
                    itemCount: controller.filteredMeals.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItem(controller.filteredMeals[index]);
                    },
                  ));
  }

  Widget _buildMenuItem(
    MealModel meal,
  ) {
    final controller = Get.find<StaffMealSelectionController>();

    // Ensure every meal has a switch controller
    if (!controller.switchControllers.containsKey(meal.id)) {
      controller.switchControllers[meal.id!] =
          ValueNotifier<bool>(meal.availability == 'available');
    }

    final switchController = controller.switchControllers[meal.id]!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image from Firestore
            meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                ? Image.network(
                    meal.imageUrl!,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/gravy.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/gravy.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          meal.name ?? 'Unnamed Item',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${meal.price ?? "0"}',
                    style: AppTextStyles.MetropolisMedium.copyWith(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Row for switch and availability text
                  Row(
                    children: [
                      // Advanced Switch with ValueNotifier
                      ValueListenableBuilder<bool>(
                        valueListenable: switchController,
                        builder: (context, value, child) {
                          return AdvancedSwitch(
                            controller: switchController,
                            initialValue: meal.availability == 'available',
                            activeColor: const Color(0xFFCCFD00),
                            height: 12,
                            width: 25,
                            onChanged: (newValue) {
                              controller.updateMeal(meal.id!, newValue);
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Availability text
                      // ValueListenableBuilder<bool>(
                      //   valueListenable: switchController,
                      //   builder: (context, value, child) {
                      //     return Text(
                      //       value ? 'Available' : 'Unavailable',
                      //       style: AppTextStyles.PoppinsRegular.copyWith(
                      //         fontSize: 7,
                      //         color: value ? const Color(0xFFCCFD00) : Colors.red,
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Fixed Button
  Widget _buildBottomFixedButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: CustomButton(
            height: 55,
            width: double.infinity,
            text: 'Add',
            onPressed: () {
              Get.toNamed(Routes.CAFETERIA_MEAL_DETAILS);
            },
            isLoading: RxBool(false)));
  }
}
