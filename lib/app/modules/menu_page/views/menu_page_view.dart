import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
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
                          margin: const EdgeInsets.only(top: 16), // Add some margin if needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                            color: Colors.white, // Background color for the container
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
                    _buildText(),
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
                    'Data Not Found!', // Replace with dynamic text
                    style: AppTextStyles.PoppinsBold.copyWith(
                      fontSize: 14,
                      color: AppColors.blackColor,
                    ),
                  ),
                )
              : controller.meals.isEmpty
                  ? Text(
                      'Meal Not Available', // Replace with dynamic text
                      style: AppTextStyles.PoppinsBold.copyWith(
                        fontSize: 14,
                        color: AppColors.blackColor,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredMeals.length, // 3 items in the list
                      itemBuilder: (context, index) {
                        return Obx(() => _buildCafeteriaItem(index, context,
                            controller.filteredMeals[index])); // Wrap in Obx to listen for changes
                      },
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
              controller.scheduleModel.removeWhere((meal) => meal.mealId == updatedMeal.mealId);

              // Remove meal from list safely
              mealsList.remove(meal);

              // Ensure schedule has repeatOn before removing
              if (schedule.repeatOn != null) {
                schedulwModel.removeWhere((s) => s.repeatOn == schedule.repeatOn);
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
          print("Saved meals: ${controller.scheduleModel.map((e) => e.mealId).toList()}");
        },
        child: Container(
          height: 127, // Adjusted height to fit all content comfortably
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: controller.selectedIndexes.contains(index)
                ? const Color(0xFFFC6011).withOpacity(0.2) // Background for selected item
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
                        controller.filteredMeals[index].imageUrl!, // Replace with actual image path
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: const Color(0xFFFC6011).withOpacity(0.2))),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                      ],
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
      child: Text('Cafeteria Name',
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
                print("Selected Meal Models:");
                for (var meal in controller.scheduleModel) {
                  print(
                      "Meal ID: ${meal.mealId}, Repeat Every: ${meal.repeatEvery}, Available At: ${meal.availableAt}, Repeat On: ${meal.repeatOn}");
                }

                if (controller.selectedIndexes.isEmpty) {
                  Get.snackbar('Error', 'Please select a meal');
                } else {
                  // print(
                  //   "Meal ID: ${controller.cafeModel});");
                  print(
                      "parentController.cafeteriaNameList[0] id is ${controller.cafeModel[0].cafeteriaName}");

                  Get.toNamed(
                    Routes.CHILDREN_DETAILS,
                    arguments: {
                      'scheduleModel': controller.scheduleModel,
                      'cafeModel': controller.cafeModel,
                      'mealList': mealsList,
                      'selectedMealData': parentSelectedMeals,
                      'childData': controller.childData,
                      "imageFile": controller.childImageFile, // Passing the image file

                    },
                  );
                }
              },
              isLoading: controller.isLoading.value),
        ));
  }
}
