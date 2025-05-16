import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/app/modules/parent_children_edit/controller/parent_children_edit_controller.dart';
import 'package:snacktag/app/modules/parents_children_details/controllers/parents_children_details_controller.dart';
import 'package:snacktag/app/modules/parents_children_details/views/parents_children_details_view.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/meal_shedule_model.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_selected_meals.dart';
import 'package:snacktag/services/parents/add_children_service.dart';
import 'package:snacktag/services/parents/school_cafaterias_model.dart';

import '../../../../widgets/custom_dialog_schedule.dart';

class ChildrenDetailsController extends GetxController {
  final AddChildrenService addChildrenService = AddChildrenService();
  // Observable for selected payment option
  final selectedPaymentOption = 'Meal Selection'.obs;
  late ScheduleDialogController scheduleController;
  final isLoading = false.obs;
  // Observable for selected meal option
  final selectedClassRoomDeliveryOption = 'No'.obs;

  // ==  === previous screen collected data
  var cafeModel = <CafeteriaDetailsParents>[]; // Initialize list
  final meals = RxList<MealModel>();
  final scheduleData = RxList<MealSheduleModel>();
  final selectedMealData = RxList<ParentSelectedMeals>();
  // ============ main model for saving children data ============
  var parentsAddChild = ParentsAddChildren();
  // ============ main model for saving children data ============
  // ============ Getting Data From Parent Controller  ============
  final ParentsChildrenDetailsController parentController =
      Get.find<ParentsChildrenDetailsController>();
  final noOfChildren = 0.obs;
  final allChildrenAreInSameSchool = false.obs;

  // Observable for selected meal option
  final selectedDurationOption = 'Weekly'.obs;

  File? childImageFile;

  @override
  void onInit() {
    super.onInit();

    // Initialize reactive collections before accessing arguments
    meals.value = [];
    scheduleData.value = [];
    selectedMealData.value = [];

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      var receivedImageFile = Get.arguments["imageFile"] as File?;
      // Assign arguments to existing observable lists
      var receivedSchedule =
          Get.arguments['scheduleModel'] as List<MealSheduleModel>?;
      var receivedCafe =
          Get.arguments['cafeModel'] as List<CafeteriaDetailsParents>?;
      var receivedChildData = Get.arguments['childData'] as ParentsAddChildren;
      var receivedMeal = Get.arguments['mealList'] as List<MealModel>?;

      // ✅ Fix: Retrieve selectedMealData as a list
      var receivedSelectedMeal =
          Get.arguments['selectedMealData'] as List<ParentSelectedMeals>?;
      parentsAddChild = receivedChildData;

      // Use value assignment instead of assignAll for reactive collections
      if (receivedSelectedMeal != null) {
        selectedMealData.value = receivedSelectedMeal;
      }

      if (receivedSchedule != null) {
        scheduleData.value = receivedSchedule;
      }

      if (receivedCafe != null) {
        cafeModel = receivedCafe;
      }

      if (receivedMeal != null) {
        meals.value = receivedMeal;
      }

      if (receivedImageFile != null) {
        childImageFile = receivedImageFile;
      }
    }

    try {
      scheduleController = Get.find<ScheduleDialogController>();
    } catch (e) {
      print("ScheduleDialogController not found: $e");
    }

    // Call update() at the end to trigger a rebuild
    update();
  }

// ============  saving children data ============
  Future<void> addChildren() async {
    print("[UpdatingChildrenMealData] Starting addChildren() method");
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      print("[UpdatingChildrenMealData] ERROR: No authenticated user found");
      Get.snackbar("Error", "You are not logged in. Please login again.");
      return;
    }

    print("[UpdatingChildrenMealData] User ID: ${user.uid}");
    print(
        "[UpdatingChildrenMealData] All children same school: ${parentController.allChildrenSameSchool.value}");
    print(
        "[UpdatingChildrenMealData] Cafeteria name: ${cafeModel[0].cafeteriaName}");
    print(
        "[UpdatingChildrenMealData] Selected meal data count: ${selectedMealData.length}");
    print(
        "[UpdatingChildrenMealData] Selected classroom delivery: ${selectedClassRoomDeliveryOption.value}");

    // Get the gender from parent controller
    String childGender = parentController.genders[selectedIndex];
    print("[UpdatingChildrenMealData] Child gender: $childGender");

    var isSuccess = false.obs;

    isLoading.value = true;

    // Process each meal and calculate scheduled dates
    for (var meal in selectedMealData) {
      if (meal.schedule != null) {
        List<String> scheduledDates = calculateScheduledDates(meal.schedule!);
        meal.scheduledDates = scheduledDates;

        print("[UpdatingChildrenMealData] Meal: ${meal.mealName}");
        print("[UpdatingChildrenMealData] Schedule: ${meal.schedule}");
        print(
            "[UpdatingChildrenMealData] Calculated dates: ${meal.scheduledDates}");
      }
    }

    final finalChildId =
        '${parentsAddChild.schoolName?.replaceAll(' ', '_')}_${parentsAddChild.childSchoolID}';

    try {
      // Create the data model for adding a child
      ParentsAddChildren parentsAddChildren = ParentsAddChildren(
        parentId: user.uid,
        classroomDelivery: selectedClassRoomDeliveryOption.value,
        numberOfChildren: parentController.numberOfChildren.value.toString(),
        allChildrenAreInSameSchool:
            parentController.allChildrenSameSchool.value,
        childId: finalChildId,
        childName: parentsAddChild.childName,
        childSchoolID: parentsAddChild.childSchoolID,
        childImageUrl: parentsAddChild.childImageUrl,
        childGender: childGender, // Use the selected gender
        schoolName: parentsAddChild.schoolName,
        cafeteriaName: cafeModel[0].cafeteriaName,
        selectedMealMenuData:
            selectedMealData.isNotEmpty ? selectedMealData : null,
        date: DateTime.now().toIso8601String(),
      );

      print("[UpdatingChildrenMealData] Child data prepared for Firestore:");
      print(
          "[UpdatingChildrenMealData] Child ID: ${parentsAddChildren.childId}");
      print(
          "[UpdatingChildrenMealData] Child name: ${parentsAddChildren.childName}");
      print(
          "[UpdatingChildrenMealData] School name: ${parentsAddChildren.schoolName}");
      print(
          "[UpdatingChildrenMealData] School ID: ${parentsAddChildren.childSchoolID}");
      print(
          "[UpdatingChildrenMealData] Classroom delivery: ${parentsAddChildren.classroomDelivery}");

      if (selectedMealData.isNotEmpty) {
        for (int i = 0; i < selectedMealData.length; i++) {
          print("[UpdatingChildrenMealData] Selected meal #${i + 1}:");
          print(
              "[UpdatingChildrenMealData]   - Name: ${selectedMealData[i].mealName}");
          print(
              "[UpdatingChildrenMealData]   - Price: ${selectedMealData[i].mealPrice}");
          print(
              "[UpdatingChildrenMealData]   - Schedule: ${selectedMealData[i].scheduleStatement}");
        }
      } else {
        print("[UpdatingChildrenMealData] No meals selected");
      }

      parentController.addedChildrenIdList[selectedIndex] =
          parentsAddChildren.childId!;

      print(
          "[UpdatingChildrenMealData] Updated child ID in parent controller: ${parentController.addedChildrenIdList[selectedIndex]}");
      print(
          "[UpdatingChildrenMealData] Calling addChildrenService.addOrUpdateChild()");

      isSuccess.value = await addChildrenService.addOrUpdateChild(
          parentsAddChildren, parentsAddChild.childImageUrl);

      print(
          "[UpdatingChildrenMealData] addOrUpdateChild result: ${isSuccess.value}");

      if (isSuccess.value) {
        print("[UpdatingChildrenMealData] Child added successfully");
        parentController.isChildrenAddedSuccessfully[selectedIndex] = true;
        Get.until(
            (route) => route.settings.name == Routes.PARENTS_CHILDREN_DETAILS);

        Get.snackbar("Success", "Child added successfully!");
      } else {
        print("[UpdatingChildrenMealData] ERROR: Failed to add child");
        Get.snackbar("Error", "Failed to add child. Please try again.");
      }
    } catch (e) {
      print("[UpdatingChildrenMealData] EXCEPTION: Error adding child: $e");
      print("[UpdatingChildrenMealData] Stack trace: ${StackTrace.current}");
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}");
    } finally {
      isLoading.value = false;
      print("[UpdatingChildrenMealData] addChildren() completed");
    }
  }
  // ============  Update  children data ============

  Future<void> updateChildren() async {
    print("[UpdatingChildrenMealData] Starting updateChildren() method");
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      print("[UpdatingChildrenMealData] ERROR: No authenticated user found");
      Get.snackbar("Error", "You are not logged in. Please login again.");
      return;
    }

    print("[UpdatingChildrenMealData] User ID: ${user.uid}");
    print(
        "[UpdatingChildrenMealData] All children same school: ${parentController.allChildrenSameSchool.value}");
    print(
        "[UpdatingChildrenMealData] Cafeteria name: ${cafeModel[0].cafeteriaName}");
    print(
        "[UpdatingChildrenMealData] Selected meal data count: ${selectedMealData.length}");
    print(
        "[UpdatingChildrenMealData] Selected classroom delivery: ${selectedClassRoomDeliveryOption.value}");

    var isSuccess = false.obs;
    ParentsChildrenEditController pChildEditController =
        Get.find<ParentsChildrenEditController>();

    print("[UpdatingChildrenMealData] Edit controller found");
    print(
        "[UpdatingChildrenMealData] Child ID from edit controller: ${pChildEditController.childData.id}");
    print(
        "[UpdatingChildrenMealData] Child name: ${parentsAddChild.childName}");

    isLoading.value = true;

    try {
      print(
          "[UpdatingChildrenMealData] Selected image path: ${pChildEditController.selectedImage.value?.path ?? 'No new image'}");
      print(
          "[UpdatingChildrenMealData] Current image URL: ${pChildEditController.imageUrl.value}");

      ParentsAddChildren editChildrenData = ParentsAddChildren(
        id: pChildEditController.childData.id,
        parentId: user.uid,
        classroomDelivery: selectedClassRoomDeliveryOption.value,
        numberOfChildren: pChildEditController.childData.numberOfChildren,
        allChildrenAreInSameSchool:
            parentController.allChildrenSameSchool.value,
        childId: pChildEditController.childData.childId,
        childName: parentsAddChild.childName,
        date: DateTime.now().toIso8601String(),
        childSchoolID: parentsAddChild.childSchoolID,
        childImageUrl: pChildEditController.selectedImage.value?.path ??
            pChildEditController.imageUrl.value,
        schoolName: parentsAddChild.schoolName,
        cafeteriaName: cafeModel[0].cafeteriaName,
        selectedMealMenuData:
            selectedMealData.isNotEmpty ? selectedMealData : null,
      );

      print(
          "[UpdatingChildrenMealData] Child data prepared for Firestore update:");
      print("[UpdatingChildrenMealData] Document ID: ${editChildrenData.id}");
      print("[UpdatingChildrenMealData] Child ID: ${editChildrenData.childId}");
      print(
          "[UpdatingChildrenMealData] Child name: ${editChildrenData.childName}");
      print(
          "[UpdatingChildrenMealData] School name: ${editChildrenData.schoolName}");
      print(
          "[UpdatingChildrenMealData] School ID: ${editChildrenData.childSchoolID}");
      print(
          "[UpdatingChildrenMealData] Classroom delivery: ${editChildrenData.classroomDelivery}");
      print("[UpdatingChildrenMealData] Date: ${editChildrenData.date}");

      if (selectedMealData.isNotEmpty) {
        for (int i = 0; i < selectedMealData.length; i++) {
          print("[UpdatingChildrenMealData] Selected meal #${i + 1}:");
          print(
              "[UpdatingChildrenMealData]   - Name: ${selectedMealData[i].mealName}");
          print(
              "[UpdatingChildrenMealData]   - Price: ${selectedMealData[i].mealPrice}");
          print(
              "[UpdatingChildrenMealData]   - Schedule: ${selectedMealData[i].scheduleStatement}");
        }
      } else {
        print("[UpdatingChildrenMealData] No meals selected for update");
      }

      print(
          "[UpdatingChildrenMealData] Calling addChildrenService.updateChildren()");

      isSuccess.value = await addChildrenService.updateChildren(
          user.uid,
          pChildEditController.childData.childId!,
          editChildrenData,
          pChildEditController.selectedImage.value?.path ??
              pChildEditController.imageUrl.value);

      print(
          "[UpdatingChildrenMealData] updateChildren result: ${isSuccess.value}");

      if (isSuccess.value) {
        print("[UpdatingChildrenMealData] Child updated successfully");
        print("[UpdatingChildrenMealData] Navigating to landing page");
        Get.offNamed(Routes.LANDING_PAGE);
        Get.snackbar("Success", "Child updated successfully!");
      } else {
        print("[UpdatingChildrenMealData] ERROR: Failed to update child");
        Get.snackbar("Error", "Failed to update child. Please try again.");
      }
    } catch (e) {
      print("[UpdatingChildrenMealData] EXCEPTION: Error updating child: $e");
      print("[UpdatingChildrenMealData] Stack trace: ${StackTrace.current}");
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}");
    } finally {
      isLoading.value = false;
      print("[UpdatingChildrenMealData] updateChildren() completed");
    }
  }

  // Update the selected option
  void updatePaymentOption(String option) {
    selectedPaymentOption.value = option;
  }

  // Update the selected option
  void updateDurationOption(String option) {
    selectedDurationOption.value = option;
  }

  // Update the selected option
  void updateClassRoomDeliveryOption(String option) {
    selectedClassRoomDeliveryOption.value = option;
  }

  /// Calculates the scheduled dates for a meal based on its schedule configuration.
  ///
  /// This function takes a [Schedule] object and generates a list of dates (in dd-MM-yyyy format)
  /// when the meal will be served, starting from today until the end date determined by
  /// the repeat count and repeat frequency (weekly or monthly).
  ///
  /// Parameters:
  /// - [schedule]: The Schedule object containing repeat configuration:
  ///   - repeatCount: Number of weeks/months to repeat
  ///   - repeatEvery: Frequency ('week' or 'month')
  ///   - repeatOn: List of days when meal is served (e.g., ['Monday', 'Wednesday', 'Friday'])
  ///
  /// Returns:
  /// A List<String> containing dates in 'dd-MM-yyyy' format when the meal will be served.
  ///
  /// Example:
  /// For a weekly schedule repeating for 4 weeks on Monday and Wednesday:
  /// - Input: Schedule(repeatCount: '4', repeatEvery: 'week', repeatOn: ['Monday', 'Wednesday'])
  /// - Output: ['01-05-2023', '03-05-2023', '08-05-2023', '10-05-2023', '15-05-2023', '17-05-2023', '22-05-2023', '24-05-2023']
  List<String> calculateScheduledDates(Schedule schedule) {
    List<String> scheduledDates = [];
    DateTime today = DateTime.now();

    // Default to 1 if repeatCount is null or empty
    int repeatCount = int.tryParse(schedule.repeatCount ?? '1') ?? 1;

    // Get the repeat days
    List<String> repeatDays = schedule.repeatOn ?? [];
    if (repeatDays.isEmpty) {
      print("[CalculateScheduledDates] No repeat days specified");
      return scheduledDates;
    }

    // Convert day names to lowercase for case-insensitive comparison
    List<String> lowerCaseRepeatDays =
        repeatDays.map((day) => day.trim().toLowerCase()).toList();

    // Calculate end date based on repeat type and count
    DateTime endDate;
    if (schedule.repeatEvery == 'week') {
      // For weekly repeats, add the specified number of weeks
      endDate = today.add(Duration(days: 7 * repeatCount));
    } else if (schedule.repeatEvery == 'month') {
      // For monthly repeats, add the specified number of months
      endDate = DateTime(today.year, today.month + repeatCount, today.day);
    } else {
      // Default to 1 week if repeatEvery is not specified
      endDate = today.add(Duration(days: 7));
    }

    print("[CalculateScheduledDates] Today: $today");
    print("[CalculateScheduledDates] End date: $endDate");
    print("[CalculateScheduledDates] Repeat every: ${schedule.repeatEvery}");
    print("[CalculateScheduledDates] Repeat count: $repeatCount");
    print("[CalculateScheduledDates] Repeat days: $lowerCaseRepeatDays");

    // Loop through each day from today to end date
    for (DateTime date = today;
        date.isBefore(endDate);
        date = date.add(Duration(days: 1))) {
      // Get the day name for the current date
      String dayName = DateFormat('EEEE').format(date).toLowerCase();

      // Check if this day is in the repeat days
      if (lowerCaseRepeatDays.contains(dayName)) {
        // If weekly, check if within the repeat count
        if (schedule.repeatEvery == 'week') {
          int weeksSinceStart = date.difference(today).inDays ~/ 7;
          if (weeksSinceStart < repeatCount) {
            scheduledDates.add(DateFormat('dd-MM-yyyy').format(date));
          }
        }
        // If monthly, check if the day of month matches and within repeat count
        else if (schedule.repeatEvery == 'month') {
          int monthsSinceStart =
              (date.year - today.year) * 12 + (date.month - today.month);
          if (monthsSinceStart < repeatCount) {
            scheduledDates.add(DateFormat('dd-MM-yyyy').format(date));
          }
        }
        // For any other repeat type, just add the date
        else {
          scheduledDates.add(DateFormat('dd-MM-yyyy').format(date));
        }
      }
    }

    print(
        "[CalculateScheduledDates] Generated ${scheduledDates.length} scheduled dates length");
    return scheduledDates;
  }
}
