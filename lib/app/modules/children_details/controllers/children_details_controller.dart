import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  RxString selectedPaymentOption = 'Meal Selection'.obs;
  late ScheduleDialogController scheduleController;
  var isLoading = false.obs;
  // Observable for selected meal option
  RxString selectedClassRoomDeliveryOption = 'No'.obs;

  // ==  === previous screen collected data
  var cafeModel = <CafeteriaDetailsParents>[]; // Initialize list
  var meals = <MealModel>[].obs;
  var scheduleData = <MealSheduleModel>[].obs;
  var selectedMealData = <ParentSelectedMeals>[].obs;
  // ============ main model for saving children data ============
  var parentsAddChild = ParentsAddChildren();
// ============ main model for saving children data ============
// ============ Getting Data From Parent Controller  ============
  final ParentsChildrenDetailsController parentController =
      Get.find<ParentsChildrenDetailsController>();
  var noOfChildren = 0.obs;
  var allChildrenAreInSameSchool = false.obs;

  // ============ Getting Data From Parent Controller  ============
  File? childImageFile;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
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
      if (receivedSelectedMeal != null) {
        selectedMealData
            .assignAll(receivedSelectedMeal); // Assign data to observable list
      }

      if (receivedSchedule != null) {
        scheduleData
            .assignAll(receivedSchedule); // Assign data to observable list
      }

      if (receivedCafe != null) {
        cafeModel.assignAll(receivedCafe);
      }
      if (receivedMeal != null) {
        meals.assignAll(receivedMeal);
      }
      if (receivedImageFile != null) {
        childImageFile = receivedImageFile;
      }
    }
    scheduleController = Get.find<ScheduleDialogController>();
  }

// ============  saving children data ============
  Future<void> addChildren() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    print("user id is ${user!.uid}");
    print("user id is ${parentController.allChildrenSameSchool.value}");
    print(
        "parentController.cafeteriaNameList[0] id is ${parentsAddChild.cafeteriaName}");
    var isSuccess = false.obs;

    isLoading.value = true;
    ParentsAddChildren parentsAddChildren = ParentsAddChildren(
      parentId: user.uid,
      classroomDelivery: selectedClassRoomDeliveryOption.value,
      numberOfChildren: parentController.numberOfChildren.value.toString(),
      allChildrenAreInSameSchool: parentController.allChildrenSameSchool.value,
      childId: parentController.addedChildrenIdList[selectedIndex].isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : parentController.addedChildrenIdList[selectedIndex],
      childName: parentsAddChild.childName,
      childSchoolID: parentsAddChild.childSchoolID,
      childImageUrl: parentsAddChild.childImageUrl,
      schoolName: parentsAddChild.schoolName,
      cafeteriaName: cafeModel[0].cafeteriaName,
      selectedMealMenuData:
          selectedMealData.isNotEmpty ? selectedMealData : null,
    );
    print(
        " Index out of range :  ,,,, value ${parentController.addedChildrenIdList[selectedIndex].isEmpty}");
    parentController.addedChildrenIdList[selectedIndex] =
        parentsAddChildren.childId!;

    print(" Index out of range :  ,,,, value ${parentsAddChildren.childId}");
    print(
        " Index out of range :  ,,,, value ${parentController.addedChildrenIdList[selectedIndex]}");

    isSuccess.value = await addChildrenService.addOrUpdateChild(
        parentsAddChildren, parentsAddChild.childImageUrl);
    isLoading.value = false;

    if (isSuccess.value) {
      print(
          " Index out of range :  ,,,, value ${parentController.isChildrenAddedSuccessfully.length}");
      parentController.isChildrenAddedSuccessfully[selectedIndex] = true;
      // parentController.updateLastChildStatus(true);
      // parentController.isChildrenAddedSuccessfully[index] = true; // or false
      Get.until(
          (route) => route.settings.name == Routes.PARENTS_CHILDREN_DETAILS);

      Get.snackbar("Success", "Child added successfully!");
    } else {
      Get.snackbar("Error", "Failed to add child. Please try again.");
    }
    isLoading.value = false;
  }
  // ============  Update  children data ============

  Future<void> updateChildren() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    print("user id is ${user!.uid}");
    print("user id is ${parentController.allChildrenSameSchool.value}");
    print(
        "parentController.cafeteriaNameList[0] id is ${parentsAddChild.cafeteriaName}");
    var isSuccess = false.obs;
    ParentsChildrenEditController pChildEditController =
        Get.find<ParentsChildrenEditController>();
    isLoading.value = true;
    print(
        "parentController Edit img  ${pChildEditController.selectedImage.value?.path ?? pChildEditController.imageUrl.value}");

    ParentsAddChildren editChildrenData = ParentsAddChildren(
      id: pChildEditController.childData.id,
      parentId: user.uid,
      classroomDelivery: selectedClassRoomDeliveryOption.value,
      numberOfChildren: pChildEditController.childData.numberOfChildren,
      allChildrenAreInSameSchool: parentController.allChildrenSameSchool.value,
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
    // // print(" Index out of range :  ,,,, value ${parentsAddChildren.childImageUrl}");
    //
    isSuccess.value = await addChildrenService.updateChildren(
        user.uid,
        pChildEditController.childData.id!,
        editChildrenData,
        pChildEditController.selectedImage.value?.path ??
            pChildEditController.imageUrl.value);
    isLoading.value = false;

    if (isSuccess.value) {
      print(" Index out of range :  ,,,, value ${editChildrenData.schoolName}");

      // parentController.updateLastChildStatus(true);
      Get.offNamed(Routes.LANDING_PAGE);

      Get.snackbar("Success", "Child added successfully!");
    } else {
      Get.snackbar("Error", "Failed to add child. Please try again.");
    }
    isLoading.value = false;
  }

  // Update the selected option
  void updatePaymentOption(String option) {
    selectedPaymentOption.value = option;
  }

  // Observable for selected meal option
  RxString selectedDurationOption = 'Weekly'.obs;

  // Update the selected option
  void updateDurationOption(String option) {
    selectedDurationOption.value = option;
  }

  // Update the selected option
  void updateClassRoomDeliveryOption(String option) {
    selectedClassRoomDeliveryOption.value = option;
  }
}
