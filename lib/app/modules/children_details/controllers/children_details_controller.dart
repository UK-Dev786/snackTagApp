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
    print("[UpdatingChildrenMealData] Starting addChildren() method");
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    
    if (user == null) {
      print("[UpdatingChildrenMealData] ERROR: No authenticated user found");
      Get.snackbar("Error", "You are not logged in. Please login again.");
      return;
    }
    
    print("[UpdatingChildrenMealData] User ID: ${user.uid}");
    print("[UpdatingChildrenMealData] All children same school: ${parentController.allChildrenSameSchool.value}");
    print("[UpdatingChildrenMealData] Cafeteria name: ${cafeModel[0].cafeteriaName}");
    print("[UpdatingChildrenMealData] Selected meal data count: ${selectedMealData.length}");
    print("[UpdatingChildrenMealData] Selected classroom delivery: ${selectedClassRoomDeliveryOption.value}");
    
    var isSuccess = false.obs;

    isLoading.value = true;
    
    try {
      // Create the data model for adding a child
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
      
      print("[UpdatingChildrenMealData] Child data prepared for Firestore:");
      print("[UpdatingChildrenMealData] Child ID: ${parentsAddChildren.childId}");
      print("[UpdatingChildrenMealData] Child name: ${parentsAddChildren.childName}");
      print("[UpdatingChildrenMealData] School name: ${parentsAddChildren.schoolName}");
      print("[UpdatingChildrenMealData] School ID: ${parentsAddChildren.childSchoolID}");
      print("[UpdatingChildrenMealData] Classroom delivery: ${parentsAddChildren.classroomDelivery}");
      
      if (selectedMealData.isNotEmpty) {
        for (int i = 0; i < selectedMealData.length; i++) {
          print("[UpdatingChildrenMealData] Selected meal #${i+1}:");
          print("[UpdatingChildrenMealData]   - Name: ${selectedMealData[i].mealName}");
          print("[UpdatingChildrenMealData]   - Price: ${selectedMealData[i].mealPrice}");
          print("[UpdatingChildrenMealData]   - Schedule: ${selectedMealData[i].scheduleStatement}");
        }
      } else {
        print("[UpdatingChildrenMealData] No meals selected");
      }
      
      parentController.addedChildrenIdList[selectedIndex] =
          parentsAddChildren.childId!;

      print("[UpdatingChildrenMealData] Updated child ID in parent controller: ${parentController.addedChildrenIdList[selectedIndex]}");
      print("[UpdatingChildrenMealData] Calling addChildrenService.addOrUpdateChild()");

      isSuccess.value = await addChildrenService.addOrUpdateChild(
          parentsAddChildren, parentsAddChild.childImageUrl);
      
      print("[UpdatingChildrenMealData] addOrUpdateChild result: ${isSuccess.value}");
      
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
    print("[UpdatingChildrenMealData] All children same school: ${parentController.allChildrenSameSchool.value}");
    print("[UpdatingChildrenMealData] Cafeteria name: ${cafeModel[0].cafeteriaName}");
    print("[UpdatingChildrenMealData] Selected meal data count: ${selectedMealData.length}");
    print("[UpdatingChildrenMealData] Selected classroom delivery: ${selectedClassRoomDeliveryOption.value}");
    
    var isSuccess = false.obs;
    ParentsChildrenEditController pChildEditController =
        Get.find<ParentsChildrenEditController>();
        
    print("[UpdatingChildrenMealData] Edit controller found");
    print("[UpdatingChildrenMealData] Child ID from edit controller: ${pChildEditController.childData.id}");
    print("[UpdatingChildrenMealData] Child name: ${parentsAddChild.childName}");
    
    isLoading.value = true;
    
    try {
      print("[UpdatingChildrenMealData] Selected image path: ${pChildEditController.selectedImage.value?.path ?? 'No new image'}");
      print("[UpdatingChildrenMealData] Current image URL: ${pChildEditController.imageUrl.value}");

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
      
      print("[UpdatingChildrenMealData] Child data prepared for Firestore update:");
      print("[UpdatingChildrenMealData] Document ID: ${editChildrenData.id}");
      print("[UpdatingChildrenMealData] Child ID: ${editChildrenData.childId}");
      print("[UpdatingChildrenMealData] Child name: ${editChildrenData.childName}");
      print("[UpdatingChildrenMealData] School name: ${editChildrenData.schoolName}");
      print("[UpdatingChildrenMealData] School ID: ${editChildrenData.childSchoolID}");
      print("[UpdatingChildrenMealData] Classroom delivery: ${editChildrenData.classroomDelivery}");
      print("[UpdatingChildrenMealData] Date: ${editChildrenData.date}");
      
      if (selectedMealData.isNotEmpty) {
        for (int i = 0; i < selectedMealData.length; i++) {
          print("[UpdatingChildrenMealData] Selected meal #${i+1}:");
          print("[UpdatingChildrenMealData]   - Name: ${selectedMealData[i].mealName}");
          print("[UpdatingChildrenMealData]   - Price: ${selectedMealData[i].mealPrice}");
          print("[UpdatingChildrenMealData]   - Schedule: ${selectedMealData[i].scheduleStatement}");
        }
      } else {
        print("[UpdatingChildrenMealData] No meals selected for update");
      }
      
      print("[UpdatingChildrenMealData] Calling addChildrenService.updateChildren()");
      
      isSuccess.value = await addChildrenService.updateChildren(
          user.uid,
          pChildEditController.childData.id!,
          editChildrenData,
          pChildEditController.selectedImage.value?.path ??
              pChildEditController.imageUrl.value);
      
      print("[UpdatingChildrenMealData] updateChildren result: ${isSuccess.value}");
      
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
