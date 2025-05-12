import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_fonts.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/models/parents_models/parent_selected_meals.dart';
import 'package:snacktag/widgets/Custom_search_textfield.dart';
import 'package:snacktag/widgets/custom_dialog_schedule.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';

import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/menu_page_controller.dart';

class MenuPageView extends GetView<MenuPageController> {
  MenuPageView({super.key});
  var mealsList = <MealModel>[].obs;
  var schedulwModel = <Schedule>[].obs;
  var parentSelectedMeals = <ParentSelectedMeals>[].obs;

  ParentSelectedMeals selectedMeals = ParentSelectedMeals();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Set the background color to white

        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 42,
            bottom: 24,
            left: 4,
            right: 4,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Get.back(); // Navigate back to the previous screen
                        },
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
                    const SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'SELECT MEAL',
                        style: AppTextStyles.MetropolisMedium.copyWith(
                            color: Color(0xFF434343), fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                    _buildSearchField(controller.searchTextController),

                    // _buildSearchField(textController),
                    const SizedBox(height: 36),
                    // _buildText(),
                    _buildCafeteriaList(context),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              _buildBottomFixedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCafeteriaList(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : controller.isDataFound.value == true
              ? Center(
                  child: Text(
                    'Data Not Found!',
                    style: AppTextStyles.PoppinsBold.copyWith(
                      fontSize: 14,
                      color: AppColors.blackColor,
                    ),
                  ),
                )
              : controller.meals.isEmpty
                  ? Text(
                      'Meal Not Available',
                      style: AppTextStyles.PoppinsBold.copyWith(
                        fontSize: 14,
                        color: AppColors.blackColor,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 8,
                            childAspectRatio: constraints.maxWidth /
                                (constraints.maxWidth * 1.42),
                          ),
                          itemCount: controller.filteredMeals.length,
                          itemBuilder: (context, index) {
                            return Obx(() => _buildGridMenuItem(index, context,
                                controller.filteredMeals[index]));
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildGridMenuItem(int index, BuildContext context, MealModel meal) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: controller.selectedIndexes.contains(index)
            ? const Color(0xFFFC6011)
                .withOpacity(0.2) // Background for selected item
            : Colors.white, // Default background
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - reduced height
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: meal.imageUrl != null
                ? Image.network(
                    meal.imageUrl!,
                    height: 90, // Reduced height
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 90, // Reduced height
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey),
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/gravy.png',
                    height: 90, // Reduced height
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),

          // Name and price - more compact padding
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6.0), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name ?? 'Unnamed Item',
                        style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 10, // Smaller font
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Row with meal image and meal info
                                  Row(
                                    children: [
                                      // Meal image on the left
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            // topLeft: Radius.circular(20),
                                            // bottomLeft: Radius.circular(20),
                                            Radius.circular(20),
                                          ),
                                          child: meal.imageUrl != null
                                              ? Image.network(
                                                  meal.imageUrl!,
                                                  height: 110,
                                                  width: 130,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/gravy.png',
                                                      height: 120,
                                                      width: 120,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  'assets/images/gravy.png',
                                                  height: 120,
                                                  width: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      // Meal info on the right
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0,
                                              top: 15,
                                              right: 15,
                                              bottom: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      Navigator.pop(context),
                                                  child: Image.asset(
                                                    AppImages.crossIcon,
                                                    height: 30,
                                                    width: 30,
                                                  ),
                                                ),
                                              ),
                                              Image.asset(
                                                AppImages.authImg,
                                                height: 60,
                                                width: 45,
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                meal.name ?? 'Unnamed Item',
                                                style: AppTextStyles
                                                    .MetropolisBold.copyWith(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Description:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontFamily:
                                                AppFonts.METROPOLIS_BOLD,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Text(
                                          'With beans, ham and grilled cheese. Served with pico de Gallo.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontFamily: AppFonts.METROPOLIS,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        const Text(
                                          'Nutritional Facts',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontFamily:
                                                AppFonts.METROPOLIS_BOLD,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        _buildNutritionalItem(
                                            'Calories:', '300-400 kcal'),
                                        _buildNutritionalItem(
                                            'Protein:', '24-28 grams'),
                                        _buildNutritionalItem(
                                            'Fat:', '14-22 grams'),
                                        _buildNutritionalItem(
                                            'Saturated fat:', '3-4 grams'),
                                        _buildNutritionalItem(
                                            'Carbohydrates:', '20-25 grams'),
                                        _buildNutritionalItem(
                                            'Fiber:', '3 grams'),
                                        _buildNutritionalItem(
                                            'Sugars:', '3-7 grams'),
                                        _buildNutritionalItem(
                                            'Sodium:', '660-1,000 mg'),
                                        _buildNutritionalItem(
                                            'Cholesterol:', '35-45 mg'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Image.asset(
                        AppImages.aboutMeal,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MX\$${meal.price ?? "0"}',
                      style: AppTextStyles.MetropolisRegular.copyWith(
                        fontSize: 10, // Smaller font
                        color: const Color(0xFF858585),
                      ),
                    ),

                    // Add button - smaller and more compact
                    SizedBox(
                      width: 45,
                      height: 22,
                      child: ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic>? result =
                              await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (BuildContext context) {
                              return ScheduleDialog(mealModel: meal);
                            },
                          );

                          bool isConfirmed = result?['isConfirmed'] ?? false;
                          MealSheduleModel? updatedMeal = result?['mealModel'];
                          String? listData = result?['scheduleStatementList'];
                          Schedule? schedule = result?['schedule'];

                          if (isConfirmed &&
                              updatedMeal != null &&
                              schedule != null) {
                            if (controller.selectedIndexes.contains(index)) {
                              controller.selectedIndexes.remove(index);

                              // Remove meal from scheduleModel
                              controller.scheduleModel.removeWhere(
                                  (meal) => meal.mealId == updatedMeal.mealId);

                              // Remove meal from list
                              mealsList.removeWhere((m) => m.id == meal.id);

                              // Remove from parentSelectedMeals
                              parentSelectedMeals
                                  .removeWhere((m) => m.mealName == meal.name);
                            } else {
                              // Add to selected meals
                              selectedMeals = ParentSelectedMeals(
                                  mealName: meal.name!,
                                  id: meal.id!,
                                  mealPrice: meal.price,
                                  scheduleStatement: listData,
                                  imageUrl: meal.imageUrl,
                                  schedule: schedule);

                              parentSelectedMeals.add(selectedMeals);
                              controller.scheduleModel.add(updatedMeal);
                              mealsList.add(meal);
                              controller.selectedIndexes.add(index);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFC6011),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 1), // Minimal padding
                          // minimumSize: const Size(50, 24), // Set minimum size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFC6C5C5)),
                          ),
                        ),
                        child: const Text('Add',
                            style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'PoppinsRegular',
                                color: Colors.black)), // Smaller text
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCafeteriaItem(
    int index,
    BuildContext context,
    MealModel meal,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () async {
          // Show the dialog and wait for the confirmation
          // bool isConfirmed = await showDialog<bool>(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return ScheduleDialog(
          //           mealModel: meal,
          //         ); // Your existing dialog
          //       },
          //     ) ??
          //     false;
          Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (BuildContext context) {
              return ScheduleDialog(mealModel: meal);
            },
          );

// Extract values safely
          bool isConfirmed = result?['isConfirmed'] ?? false;
          MealSheduleModel? updatedMeal = result?['mealModel'];
          String? listData = result?['scheduleStatementList'];
          Schedule? schedule = result?['schedule'];

          if (isConfirmed && updatedMeal != null && schedule != null) {
            if (controller.selectedIndexes.contains(index)) {
              controller.selectedIndexes.remove(index);

              // Remove meal from scheduleModel
              controller.scheduleModel
                  .removeWhere((meal) => meal.mealId == updatedMeal.mealId);

              // Remove meal from list safely
              mealsList.remove(meal);

              // Ensure schedule has repeatOn before removing
              if (schedule.repeatOn != null) {
                schedulwModel
                    .removeWhere((s) => s.repeatOn == schedule.repeatOn);
              }
              parentSelectedMeals.remove(selectedMeals);

              // Remove statement if listData is not null
              if (listData != null) {
                controller.scheduleStatementList.remove(listData);
              }
            } else {
              selectedMeals = ParentSelectedMeals(
                  mealName: meal.name!,
                  mealPrice: meal.price,
                  scheduleStatement: listData,
                  imageUrl: meal.imageUrl,
                  schedule: schedule);
              parentSelectedMeals.add(selectedMeals);
              // Add meal to scheduleModel
              controller.scheduleModel.add(updatedMeal);

              // Add meal to list safely
              mealsList.add(meal);

              // Ensure listData is not null before adding
              if (listData != null) {
                controller.scheduleStatementList.add(listData);
              }

              // Ensure schedule is valid before adding
              if (schedule.repeatOn != null) {
                schedulwModel.add(schedule);
              }

              controller.selectedIndexes.add(index);
            }
          }

          print("Confirmed indexes: ${controller.selectedIndexes}");
          print(
              "Saved meals: ${controller.scheduleModel.map((e) => e.mealId).toList()}");
        },
        child: Container(
          height: 127, // Adjusted height to fit all content comfortably
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: controller.selectedIndexes.contains(index)
                ? const Color(0xFFFC6011)
                    .withOpacity(0.2) // Background for selected item
                : Colors.white, // Default background
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              meal.imageUrl == null
                  ? const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: Colors.grey,
                      ))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        controller.filteredMeals[index]
                            .imageUrl!, // Replace with actual image path
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: const Color(0xFFFC6011)
                                        .withOpacity(0.2))),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 50,
                                color: Colors.grey,
                              ));
                        },
                      ),
                    ),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.asset(
              //     index == 0
              //         ? 'assets/images/gravy.png'
              //         : index == 1
              //             ? 'assets/images/pepper.png'
              //             : 'assets/images/roast.png',
              //     width: 100,
              //     height: 100,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              const SizedBox(width: 16),

              // Right section: Text Information and Divider
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cafeteria Name and Call Icon
                    Expanded(
                      child: Text(
                        meal.name!,
                        style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle long names
                      ),
                      // child: Text(
                      //   index == 0
                      //       ? 'Chicken Gravy'
                      //       : index == 1
                      //           ? 'Pepper Chicken'
                      //           : 'Roast Chicken',
                      //   style: AppTextStyles.MetropolisMedium.copyWith(
                      //     fontSize: 14,
                      //     color: Colors.black,
                      //   ),
                      //   overflow:
                      //       TextOverflow.ellipsis, // Handle long names
                      // ),
                    ),

                    // Collage/School Name
                    Text(
                      meal.price!, // Replace with dynamic data
                      style: AppTextStyles.MetropolisRegular.copyWith(
                        fontSize: 20,
                        color: const Color(0xFF858585),
                      ),
                    ),
                    // Text(
                    //   '\$25', // Replace with dynamic data
                    //   style: AppTextStyles.MetropolisRegular.copyWith(
                    //     fontSize: 20,
                    //     color: const Color(0xFF858585),
                    //   ),
                    // ),
                    const Spacer(),
                  ],
                ),
              ),
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
  // Widget _buildSearchField(TextEditingController textController) {
  //   return TextFieldWidget(
  //     text: 'Search Meal',
  //     textController: textController,
  //     path: 'assets/icon/search.png',
  //     isBGChangeColor: true,
  //     height: 40,
  //     isSuffixBG: true,
  //     onChanged: (value) {},
  //   );
  // }

  // "Congratulations" text in the center
  Widget _buildText() {
    return Center(
      child: Text('',
          style: AppTextStyles.PoppinsBold.copyWith(
            fontSize: 14,
            color: AppColors.blackColor,
          )),
    );
  }

  // Bottom Fixed Button
  Widget _buildBottomFixedButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Obx(
          () => CustomButton1(
              height: 55,
              width: 325,
              text: 'CONFIRM',
              onPressed: () {
                if (controller.selectedIndexes.isEmpty) {
                  Get.snackbar('Error', 'Please select a meal');
                } else {
                  print("Selected meals count: ${parentSelectedMeals.length}");
                  print(
                      "Schedule model count: ${controller.scheduleModel.length}");

                  Get.toNamed(
                    Routes.CHILDREN_DETAILS,
                    arguments: {
                      'scheduleModel': controller.scheduleModel,
                      'cafeModel': controller.cafeModel,
                      'mealList': mealsList,
                      'selectedMealData': parentSelectedMeals,
                      'childData': controller.childData,
                      "imageFile": controller.childImageFile,
                    },
                  );
                }
              },
              isLoading: controller.isLoading.value),
        ));
  }

  Widget _buildNutritionalItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontFamily: AppFonts.METROPOLIS,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontFamily: AppFonts.METROPOLIS,
            ),
          ),
        ],
      ),
    );
  }
}
