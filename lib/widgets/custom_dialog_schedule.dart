import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/models/parents_models/parent_selected_meals.dart';
import 'package:snacktag/services/parents/add_children_service.dart';
import 'package:snacktag/widgets/reuse_button.dart';

class ScheduleDialogController extends GetxController {
  final AddChildrenService addChildrenService = AddChildrenService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var mealSchedules = <MealSheduleModel>[].obs;
  RxList<String> availableTimes = <String>[].obs;

  var userId = ''.obs;
  var mealId = ''.obs;
  var isLoading = false.obs;
  var isParent = true.obs; // Default to true for safety

  @override
  void onInit() {
    super.onInit();

    // Check if the current user is a parent
    checkUserRole();

    fetchMealSchedule(userId.value, mealId.value);
  }

  // Check if the current user is a parent
  Future<void> checkUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Default to parent if not logged in (for safety)
        isParent.value = true;
        return;
      }

      // Get user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final role = userDoc.data()?['role'] as String?;
        // Set isParent to true if role is 'parents', false otherwise
        isParent.value = role == 'parents';
      } else {
        // Default to parent if document doesn't exist (for safety)
        isParent.value = true;
      }
    } catch (e) {
      // Default to parent in case of error (for safety)
      isParent.value = true;
    }
  }

  Future<void> fetchMealSchedule(String userId, String mealId) async {
    try {
      isLoading.value = true;

      // Fetch meal schedule list from service
      List<MealSheduleModel> fetchedMeals =
          await addChildrenService.getPMealShedule(userId, mealId);

      // Assign fetched list to RxList
      mealSchedules.assignAll(fetchedMeals);
      setMealScheduleRepeatOn(mealSchedules); // <-- Add this line
      setMealScheduleAvailableAt(mealSchedules);

      print("✅ Meal schedules updated. Total: ${mealSchedules.length}");
    } catch (e) {
      print("❌ Error fetching meal schedule: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setMealScheduleAvailableAt(List<MealSheduleModel> mealSchedules) {
    availableTimes.clear();
    for (var meal in mealSchedules) {
      availableTimes.addAll(meal.availableAt);
    }
  }

  final RxList<String> selectedDaysList =
      <String>[].obs; // Stores only the days received

  void setMealScheduleRepeatOn(List<MealSheduleModel> mealSchedules) {
    selectedDaysList.clear(); // Reset list

    if (mealSchedules.isNotEmpty) {
      selectedDaysList.addAll(mealSchedules.first.repeatOn);
    }

    selectedDaysList.refresh(); // Refresh UI
  }

  final RxInt repeatCount = 1.obs;
  final RxString repeatUnit = 'week'.obs;
  final RxList<bool> selectedDays = List.generate(7, (index) => false).obs;
  final RxList<bool> selectedTimes = List.generate(12, (index) => false).obs;

  // Show day selection for both week and month
  bool get showDaySelection =>
      repeatUnit.value.contains('week') || repeatUnit.value.contains('month');

  List<String> get timeUnits => ['week', 'month'];

  // List<String> get availableTimes => ['12am', '2pm', '7pm'];

  String get currentRepeatUnit {
    String baseUnit = repeatUnit.value;
    if (repeatCount.value > 1) {
      return baseUnit + 's';
    }
    return baseUnit;
  }

  void incrementCount() {
    if (repeatCount.value < 99) {
      repeatCount.value++;
    }
  }

  void decrementCount() {
    if (repeatCount.value > 1) {
      repeatCount.value--;
    }
  }

  // void toggleDay(int index) {
  //   selectedDays[index] = !selectedDays[index];
  //   selectedDays.refresh();
  // }

  void toggleDay(String day) {
    int index = selectedDaysList.indexOf(day);
    if (index != -1) {
      selectedDays[index] = !selectedDays[index]; // Toggle selection
      selectedDaysList.refresh();
    }
    print("selected index value is ${index}");
  }

  void toggleTime(int index) {
    // For parents: enforce single time slot selection
    if (isParent.value) {
      // If trying to deselect the current time, allow it
      if (selectedTimes[index]) {
        selectedTimes[index] = false;
      } else {
        // If selecting a new time, first clear all selections
        for (int i = 0; i < selectedTimes.length; i++) {
          selectedTimes[i] = false;
        }
        // Then select only the new time
        selectedTimes[index] = true;
      }
    } else {
      // For cafeteria users: allow multiple selections
      selectedTimes[index] = !selectedTimes[index];
    }

    selectedTimes.refresh();
  }

  void updateRepeatUnit(String? value) {
    print(" selected val is mm ${value}");
    if (value != null) {
      // Remove 's' if present and store base form
      repeatUnit.value = value.replaceAll('s', '');

      print(" selected val is mm ${repeatUnit.value}");

      if (value.contains('day')) {
        selectedDays.value = List.generate(7, (index) => false);
      }
    }
  }

  Map<String, dynamic> getScheduleData() {
    return {
      'repeatCount': repeatCount.value,
      'repeatUnit': currentRepeatUnit,
      'selectedDays': showDaySelection ? selectedDays.toList() : [],
    };
  }
}

class ScheduleDialog extends StatelessWidget {
  final MealModel mealModel;
  late final ScheduleDialogController controller;

  ScheduleDialog({super.key, required this.mealModel}) {
    // ✅ Ensure controller is initialized before use
    if (!Get.isRegistered<ScheduleDialogController>()) {
      Get.put(ScheduleDialogController());
    }
    controller = Get.find<ScheduleDialogController>();
  }

  @override
  Widget build(BuildContext context) {
    controller.userId.value = mealModel.userId!;
    controller.mealId.value = mealModel.id!;
    print("meal kkkjj ${mealModel.id}");
    print("meal kkkjj ${mealModel.userId}");
    controller.fetchMealSchedule(mealModel.userId!, mealModel.id!);
    final screenSize = MediaQuery.of(context).size;
    const double defaultPadding = 16.0;
    const double smallPadding = 8.0;
    String? scheduleMessage;

    return Dialog(
        backgroundColor: const Color(0xFFF2F2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          // Increased width to 98% of screen width
          width: screenSize.width - 32,
          height: screenSize.height * 0.50,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Schedule',
                style: AppTextStyles.MetropolisBold.copyWith(
                  color: const Color(0xFF434343),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Repeat every',
                    style:
                        AppTextStyles.MetropolisRegular.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: smallPadding),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: controller.decrementCount,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '-',
                                style: AppTextStyles.PoppinsRegular.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF1D1D1D),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: smallPadding),
                        Obx(() => Text(
                              '${controller.repeatCount.value}',
                              style: AppTextStyles.PoppinsRegular.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF1D1D1D),
                              ),
                            )),
                        const SizedBox(width: smallPadding),
                        GestureDetector(
                          onTap: controller.incrementCount,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '+',
                                style: AppTextStyles.PoppinsRegular.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF1D1D1D),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: smallPadding),
                  Container(
                    width: 85,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: Obx(() {
                          final List<String> options =
                              controller.timeUnits.map((unit) {
                            return controller.repeatCount.value > 1
                                ? '${unit}s'
                                : unit;
                          }).toList();

                          return DropdownButton<String>(
                            value: controller.currentRepeatUnit,
                            items: options.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: AppTextStyles.PoppinsRegular.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF1D1D1D),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: controller.updateRepeatUnit,
                            isDense: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.black, size: 12),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Available at: ',
                      style: AppTextStyles.MetropolisRegular.copyWith(
                          fontSize: 12),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(controller.availableTimes.length,
                                (index) {
                              return GestureDetector(
                                onTap: () => controller.toggleTime(index),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: controller.selectedTimes[index]
                                        ? const Color(0xFFFFF3E0)
                                        : const Color(0xFFF2F2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: controller.selectedTimes[index]
                                          ? const Color(0xFFFF9A0D)
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    controller.availableTimes[index],
                                    style: AppTextStyles.MetropolisRegular
                                        .copyWith(
                                      fontSize: 12,
                                      color: controller.selectedTimes[index]
                                          ? Colors.black87
                                          : const Color(0xFFFF9A0D),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Obx(() => controller.showDaySelection
                  ? Column(
                      children: [
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Repeat on',
                              style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        //       .asMap()
                        //       .entries
                        //       .map(
                        //         (entry) => GestureDetector(
                        //           onTap: () => controller.toggleDay(entry.key),
                        //           child: Container(
                        //             height: 32,
                        //             width: 32,
                        //             decoration: BoxDecoration(
                        //               color: controller.selectedDays[entry.key]
                        //                   ? const Color(0xFFFFF3E0)
                        //                   : const Color(0xFFF2F2F2),
                        //               border: Border.all(
                        //                 color: controller.selectedDays[entry.key]
                        //                     ? const Color(0xFFFF9A0D)
                        //                     : Colors.grey.shade400,
                        //                 width: 1.5,
                        //               ),
                        //               borderRadius: BorderRadius.circular(16),
                        //             ),
                        //             alignment: Alignment.center,
                        //             child: Text(
                        //               entry.value,
                        //               style:
                        //                   AppTextStyles.PoppinsRegular.copyWith(
                        //                 fontSize: 13,
                        //                 color: controller.selectedDays[entry.key]
                        //                     ? Colors.black87
                        //                     : const Color(0xFFFF9A0D),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //       .toList(),
                        // ),
                        SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: controller.selectedDaysList
                                .asMap()
                                .entries
                                .map(
                                  (entry) => GestureDetector(
                                    onTap: () =>
                                        controller.toggleDay(entry.value),
                                    child: Obx(() => Container(
                                          height: 32,
                                          width: 32,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 3),
                                          decoration: BoxDecoration(
                                            color: controller
                                                    .selectedDays[entry.key]
                                                ? const Color(0xFFFFF3E0)
                                                : const Color(0xFFF2F2F2),
                                            border: Border.all(
                                              color: controller
                                                      .selectedDays[entry.key]
                                                  ? const Color(0xFFFF9A0D)
                                                  : Colors.grey.shade400,
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            entry.value.substring(0,
                                                1), // Display first letter (S, M, T, etc.)
                                            style: AppTextStyles.PoppinsRegular
                                                .copyWith(
                                              fontSize: 13,
                                              color: controller
                                                      .selectedDays[entry.key]
                                                  ? Colors.black87
                                                  : const Color(0xFFFF9A0D),
                                            ),
                                          ),
                                        )),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        Obx(() {
                          final selectedTimes = controller.availableTimes
                              .asMap()
                              .entries
                              .where((entry) =>
                                  controller.selectedTimes[entry.key])
                              .map((entry) => entry.value)
                              .join(', ');

                          final selectedDays = controller.selectedDaysList
                              .asMap()
                              .entries
                              .where(
                                  (entry) => controller.selectedDays[entry.key])
                              .map((entry) => entry.value)
                              .join(', ');

                          if (selectedTimes.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          //
                          // if (controller.repeatUnit.value == 'week') {
                          //   scheduleMessage =
                          //       'Your order is scheduled for $selectedTimes on $selectedDays ${controller.repeatUnit.value}';
                          // }
                          if (controller.repeatUnit.value == 'month') {
                            scheduleMessage =
                                'Your order is scheduled for $selectedTimes on $selectedDays every week this ${controller.repeatUnit.value}.';
                          } else {
                            scheduleMessage =
                                'Your order is scheduled for $selectedTimes $selectedDays this ${controller.repeatUnit.value}.';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              scheduleMessage ?? "",
                              style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ],
                    )
                  : const SizedBox.shrink()),
              const Spacer(),
              Obx(
                () => CustomButton1(
                    text: 'Confirm',
                    onPressed: () {
                      final selectedTimes = controller.availableTimes
                          .asMap()
                          .entries
                          .where((entry) => controller.selectedTimes[entry.key])
                          .map((entry) => entry.value)
                          .join(', ');

                      final selectedDays = controller.selectedDaysList
                          .asMap()
                          .entries
                          .where((entry) => controller.selectedDays[entry.key])
                          .map((entry) => entry.value)
                          .join(', ');
                      //
                      final newschedule = MealSheduleModel(
                          mealId: mealModel.id!,
                          userId: mealModel.userId!,
                          availableAt: selectedTimes.split(','),
                          repeatOn: selectedDays.split(','),
                          repeatCount: controller.repeatCount.value.toString(),
                          repeatEvery: controller.repeatUnit.value);
                      Schedule schedule = Schedule(
                          availableAt: selectedTimes.split(','),
                          repeatOn: selectedDays.split(','),
                          repeatCount: controller.repeatCount.value.toString(),
                          repeatEvery: controller.repeatUnit.value);
                      print(
                          "Selected date ${selectedTimes}, selected days ${selectedDays}");
                      if (selectedTimes == "" || selectedDays == "") {
                        Get.snackbar("Error",
                            "Please select available Schedule time and days");
                        return;
                      } else {
                        print(
                            "Selected iiiii date ${selectedTimes}, selected days ${selectedDays}");
                        Navigator.pop(context, {
                          'isConfirmed': true, // Boolean confirmation
                          'mealModel': newschedule, // Updated meal model
                          'scheduleStatementList': scheduleMessage,
                          'schedule': schedule // Updated meal model
                        });
                      }
                    },
                    isLoading: controller.isLoading.value),
              )
            ],
          ),
        ));
  }
}
