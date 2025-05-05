//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ParentsChildrenDetailsController extends GetxController {
//   // Observable for selected option (whether all children are in the same school)
//   RxBool isSameSchool = false.obs;
//
//   // Number of children
//   RxInt numberOfChildren = 0.obs;
//
//   // List of controllers for child's data
//   RxList<TextEditingController> nameControllers = <TextEditingController>[].obs;
//   RxList<TextEditingController> idControllers = <TextEditingController>[].obs;
//
//   // Single school name controller (as it applies to all children)
//   final TextEditingController schoolNameController = TextEditingController();
//
//   @override
//   void onInit() {
//     super.onInit();
//   }
//
//   // Update whether all children are in the same school
//   void updateSameSchoolOption(bool value) {
//     isSameSchool.value = value;
//
//     if (value && idControllers.isNotEmpty) {
//       // Sync all IDs to the first controller's value when set to 'Yes'
//       String firstId = idControllers.first.text;
//       for (var controller in idControllers) {
//         controller.text = firstId;
//       }
//     }
//   }
//
//   // Sync school IDs across all controllers when `isSameSchool` is true
//   void syncSchoolIds(String newValue, int sourceIndex) {
//     if (isSameSchool.value) {
//       for (int i = 0; i < idControllers.length; i++) {
//         if (i != sourceIndex) {
//           idControllers[i].text = newValue;
//         }
//       }
//     }
//   }
//
//   // Add a new child entry
//   void addChild() {
//     var nameController = TextEditingController();
//     var idController = TextEditingController();
//
//     // Add listener to sync school IDs if required
//     final int currentIndex = idControllers.length;
//     idController.addListener(() {
//       if (isSameSchool.value) {
//         syncSchoolIds(idController.text, currentIndex);
//       }
//     });
//
//     nameControllers.add(nameController);
//     idControllers.add(idController);
//     numberOfChildren.value++;
//   }
//
//   // Remove the last child entry
//   void removeChild() {
//     if (numberOfChildren.value > 0) {
//       nameControllers.last.dispose();
//       idControllers.last.dispose();
//
//       nameControllers.removeLast();
//       idControllers.removeLast();
//       numberOfChildren.value--;
//     }
//   }
//
//   @override
//   void onClose() {
//     // Dispose controllers
//     for (var controller in nameControllers) {
//       controller.dispose();
//     }
//     for (var controller in idControllers) {
//       controller.dispose();
//     }
//     schoolNameController.dispose();
//
//     super.onClose();
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/parents/add_children_service.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';

class ParentsChildrenEditController extends GetxController {
  final AddChildrenService addChildrenService = AddChildrenService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable for selected option for classroom delivery
  RxString allChildrenSameSchool = 'No'.obs;

  // Initialize with 0 children
  // RxInt numberOfChildren = 0.obs;
  // RxBool allChildrenSameSchool = false.obs; // Default to true

  // List of controllers for child-specific data
  RxList<bool> isChildrenAddedSuccessfully = <bool>[].obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  RxString imageUrl = ''.obs;

  RxList<String> cafeteriaNameList = <String>[].obs;
  TextEditingController idControllers = TextEditingController();
  TextEditingController nameControllers = TextEditingController();
  TextEditingController schoolNameController = TextEditingController();

  RxList<String> schoolNamesList = <String>[].obs;
  // FETCHING CHILDREN DATA AGAINST PARENTS
  late ParentsAddChildren childData;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Fetch and cast the received arguments
    var childReceived = Get.arguments;

    // Ensure childReceived is not null and assign it to childData
    if (childReceived != null) {
      if (childReceived is ParentsAddChildren) {
        childData = childReceived; // Directly assign if already an object
      } else if (childReceived is Map<String, dynamic>) {
        childData =
            ParentsAddChildren.fromJson(childReceived); // Convert from JSON
      } else if (childReceived is String) {
        // If passed as a JSON-encoded string, decode it first
        Map<String, dynamic> jsonMap = jsonDecode(childReceived);
        childData = ParentsAddChildren.fromJson(jsonMap);
      }
    }

    print("Received child data id: ${childData.id}");
    // Call the function to populate text fields
    populateFields();
    // fetchChildren();

    fetchSchoolNames();
  }
  /// Function to populate text controllers with existing values
  void populateFields() {
    idControllers.text = childData.childSchoolID!;
    nameControllers.text = childData.childName!;
    schoolNameController.text = childData.schoolName!;
    imageUrl.value = childData.childImageUrl!;
  }
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('PickedFile Path${pickedFile.path}');
      selectedImage.value = File(pickedFile.path);
    }
  }

  // Fetch school names and update observable list
  Future<void> fetchSchoolNames() async {
    List<String> schools = await addChildrenService.getSchoolNames();
    schoolNamesList.assignAll(schools);

    // Print the fetched list
    print("Fetched School Names: $schoolNamesList");
  }

  // // Update the selected option
  // void updateClassRoomDeliveryOption(String option) {
  //   allChildrenSameSchool.value = option;
  //   // When switching to 'Yes', sync all IDs to the first controller's value
  //   if (option == 'Yes' && idControllers.isNotEmpty) {
  //     String firstId = idControllers[0].text;
  //     for (var controller in idControllers) {
  //       if (controller != idControllers[0]) {
  //         controller.text = firstId;
  //       }
  //     }
  //   }
  // }

  // Method to sync school IDs across all controllers
  // void syncSchoolIds(String newValue, int sourceIndex) {
  //   if (allChildrenSameSchool.value == 'Yes') {
  //     for (int i = 0; i < idControllers.length; i++) {
  //       if (i != sourceIndex) {
  //         idControllers[i].text = newValue;
  //       }
  //     }
  //   }
  // }

  // void incrementChildren() {
  //   var nameController = TextEditingController();
  //   var idController = TextEditingController();
  //   var schoolNameController = TextEditingController();
  //   String cafeteriaNameController = '';
  //
  //   File? imageFile; // Nullable File object
  //   // Add listener to the new ID controller
  //   final int currentIndex = idControllers.length;
  //   // idController.addListener(() {
  //   //   if (allChildrenSameSchool.value == 'Yes') {
  //   //     String newValue = idController.text;
  //   //     syncSchoolIds(newValue, currentIndex);
  //   //   }
  //   // });
  //
  //   nameControllers.add(nameController);
  //   idControllers.add(idController);
  //   schoolNameControllerList.add(schoolNameController);
  //   cafeteriaNameList.add(cafeteriaNameController);
  //   isChildrenAddedSuccessfully.add(false);
  //
  //   // Add image file if it's not null
  //   if (imageFile != null) {
  //     images.add(imageFile);
  //   } else {
  //     images.add(File('')); // Add an empty file if no image is selected
  //   }
  //   numberOfChildren++;
  // }

  // void decrementChildren() {
  //   if (numberOfChildren > 0) {
  //     if (nameControllers.isNotEmpty) {
  //       nameControllers.last.dispose();
  //       nameControllers.removeLast();
  //     }
  //     if (idControllers.isNotEmpty) {
  //       idControllers.last.dispose();
  //       idControllers.removeLast();
  //     }
  //     if (schoolNameControllerList.isNotEmpty) {
  //       schoolNameControllerList.last.dispose();
  //       schoolNameControllerList.removeLast();
  //     }
  //     if (cafeteriaNameList.isNotEmpty) {
  //       // cafeteriaNameList.last.dispose();
  //       cafeteriaNameList.removeLast();
  //       isChildrenAddedSuccessfully.removeLast(); // ✅ Remove last element
  //     }
  //     // if (images.isNotEmpty) {
  //     //   images.last?.delete();
  //     //   images.removeLast();
  //     // }
  //     numberOfChildren--;
  //   }
  // }
  //
  // void clear() {
  //   for (var controller in nameControllers) {
  //     controller.clear();
  //   }
  //   for (var controller in idControllers) {
  //     controller.clear();
  //   }
  //   for (var controller in schoolNameControllerList) {
  //     controller.clear();
  //   }
  //   numberOfChildren.value = 0;
  //   isChildrenAddedSuccessfully.clear();
  //   schoolNameController.text = '';
  //   images.clear();
  // }

  // @override
  // void onClose() {
  //   print(" hhhhhh ");
  //   for (var controller in nameControllers) {
  //     controller.dispose();
  //   }
  //   for (var controller in idControllers) {
  //     controller.dispose();
  //   }
  //   for (var controller in schoolNameControllerList) {
  //     controller.dispose();
  //   }
  //
  //   isChildrenAddedSuccessfully.clear();
  //   images.clear();
  //   super.onClose();
  // }
}
