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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/parents/add_children_service.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';

class ParentsChildrenDetailsController extends GetxController {
  final AddChildrenService addChildrenService = AddChildrenService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable for selected option for classroom delivery
  RxString allChildrenSameSchool = 'No'.obs;
  RxBool isYesSelected = false.obs;

  // Initialize with 0 children
  RxInt numberOfChildren = 0.obs;
  // RxBool allChildrenSameSchool = false.obs; // Default to true

  // List of controllers for child-specific data
  RxList<TextEditingController> nameControllers = <TextEditingController>[].obs;
  RxList<bool> isChildrenAddedSuccessfully = <bool>[].obs;
  RxList<TextEditingController> idControllers = <TextEditingController>[].obs;
  RxList<File?> images = <File?>[].obs; // List to store images
  // var imagesUrl = [].obs;
  RxList<String> cafeteriaNameList = <String>[].obs;
  // for single and list of schools
  RxList<TextEditingController> schoolNameControllerList =
      <TextEditingController>[].obs;
  final TextEditingController schoolNameController = TextEditingController();
  // for single and list of schools  end

  RxList<String> schoolNamesList = <String>[].obs;
  RxList<String> addedChildrenIdList = <String>[].obs;
  // FETCHING CHILDREN DATA AGAINST PARENTS
  var childrenList = <ParentsAddChildren>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchChildren();

    fetchSchoolNames();

    // ever(allChildrenSameSchool, (selectedValue) {
    //   if (selectedValue == 'Yes') {
    //     deleteChildrenByParentId();
    //     clear();
    //   } else if (selectedValue == 'No') {
    //     print("selectedValue is NO: $selectedValue");
    //   }
    // });
  }

  // DELETE THE CHILDREN AGAINST PARENTS
  Future<void> deleteChildrenByParentId(BuildContext context) async {
    var pId = _auth.currentUser;
    showDeleteConfirmationDialog(
        context,
        "If you proceed, you will need to re-enter all children because you are changing the school for your children.",
        pId!.uid);

    // Print the fetched list
    print("Parent id : $pId");
  }

  // void printdata (){
  //   for(var aa in isChildrenAddedSuccessfully){
  //     print("isChildrenAddedSuccessfully value : $aa");
  //
  //   }
  // }
  void updateLastChildStatus(bool newValue) {
    if (isChildrenAddedSuccessfully.isNotEmpty) {
      int lastIndex = isChildrenAddedSuccessfully.length - 1; // Get last index
      isChildrenAddedSuccessfully[lastIndex] = newValue; // Update last item
    } else {
      print("Error: List is empty, no index to update");
    }
  }

  // FETCH CHILDREN DATA AGAINST PARENTS
  Future<void> fetchChildren() async {
    isLoading.value = true;
    final currentParentChildren = FirebaseAuth.instance.currentUser;
    if (currentParentChildren != null) {
      List<ParentsAddChildren> children = await addChildrenService
          .fetchChildrenByParentId(currentParentChildren.uid);
      childrenList.assignAll(children);
      print("children data is  $currentParentChildren");

      // numberOfChildren.value = childrenList.length;
      // for (var child in childrenList) {
      //
      //   allChilSameSchool.add(child.allChildrenAreInSameSchool);
      //   nameControllers.add(TextEditingController(text: child.childName));
      //   idControllers.add(TextEditingController(text: child.childSchoolID));
      //   images.add(File(child.childImageUrl!));
      //   schoolNameController.text = child.schoolName!;
      //   isChildrenAddedSuccessfully.add(true);
      // }
      if (childrenList[0].allChildrenAreInSameSchool == 'Yes') {
        print(
            "Child in same school: ${childrenList[0].allChildrenAreInSameSchool}");
        allChildrenSameSchool.value =
            childrenList[0].allChildrenAreInSameSchool!;
        isYesSelected.value = true;
      } else {
        allChildrenSameSchool.value =
            childrenList[0].allChildrenAreInSameSchool!;
        isYesSelected.value = false;
      }
    }
    print("children data is empty $currentParentChildren");

    isLoading.value = false;
  }

  // FOR CHECK THE PARENTS HAVE CHILDREN OR NOT
  Future<bool> doesParentHaveChildren() async {
    final currentUser = _auth.currentUser;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection("parentsChildren") // Collection Name
        .where("parentId", isEqualTo: currentUser!.uid) // Filter by parentId
        .limit(1) // Optimize query to check only one document
        .get();
    if (querySnapshot.docs.isEmpty) {
      showCustomSnack('Please Add Children.');
    } else {
      Get.offAllNamed(Routes.LANDING_PAGE);
    }
    return querySnapshot
        .docs.isEmpty; // Returns true if at least one document exists
  }

  Future<void> pickImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Ensure list has enough elements before assigning
      while (images.length <= index) {
        images.add(null);
        // imagesUrl.add(null);
      }

      images[index] = File(pickedFile.path); // Assign image safely
      print("Image Selected for Child ${index + 1}: ${pickedFile.path}");
      // imagesUrl.value = imagesUrl[index];
      update(); // Update UI
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

  void incrementChildren() {
    var nameController = TextEditingController();
    var idController = TextEditingController();
    var schoolNameController = TextEditingController();
    String cafeteriaNameController = '';
    String addedChildId = '';

    File? imageFile; // Nullable File object
    // Add listener to the new ID controller
    final int currentIndex = idControllers.length;
    // idController.addListener(() {
    //   if (allChildrenSameSchool.value == 'Yes') {
    //     String newValue = idController.text;
    //     syncSchoolIds(newValue, currentIndex);
    //   }
    // });

    nameControllers.add(nameController);
    idControllers.add(idController);
    schoolNameControllerList.add(schoolNameController);
    cafeteriaNameList.add(cafeteriaNameController);
    addedChildrenIdList.add(addedChildId);
    isChildrenAddedSuccessfully.add(false);

    // Add image file if it's not null
    if (imageFile != null) {
      images.add(imageFile);
    } else {
      images.add(File('')); // Add an empty file if no image is selected
    }
    numberOfChildren++;
  }

  void decrementChildren() {
    if (numberOfChildren > 0) {
      if (nameControllers.isNotEmpty) {
        nameControllers.last.dispose();
        nameControllers.removeLast();
      }
      if (idControllers.isNotEmpty) {
        idControllers.last.dispose();
        idControllers.removeLast();
      }
      if (schoolNameControllerList.isNotEmpty) {
        schoolNameControllerList.last.dispose();
        schoolNameControllerList.removeLast();
      }
      if (cafeteriaNameList.isNotEmpty) {
        // cafeteriaNameList.last.dispose();
        cafeteriaNameList.removeLast();
        isChildrenAddedSuccessfully.removeLast(); // ✅ Remove last element
      }
      if (addedChildrenIdList.isNotEmpty) {
        addedChildrenIdList.removeLast();
      }
      // if (images.isNotEmpty) {
      //   images.last?.delete();
      //   images.removeLast();
      // }
      numberOfChildren--;
    }
  }

  void clear() {
    for (var controller in nameControllers) {
      controller.clear();
    }
    for (var controller in idControllers) {
      controller.clear();
    }
    for (var controller in schoolNameControllerList) {
      controller.clear();
    }

    addedChildrenIdList.value = [];
    numberOfChildren.value = 0;
    isChildrenAddedSuccessfully.clear();
    schoolNameController.text = '';
    images.clear();
  }

  @override
  void onClose() {
    print(" hhhhhh ");
    for (var controller in nameControllers) {
      controller.dispose();
    }
    for (var controller in idControllers) {
      controller.dispose();
    }
    for (var controller in schoolNameControllerList) {
      controller.dispose();
    }

    isChildrenAddedSuccessfully.clear();
    images.clear();
    super.onClose();
  }

  Future<bool?> showDeleteConfirmationDialog(
      BuildContext context, String message, String parentId) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure you want to delete All Children!",
              textAlign: TextAlign.center,
              style: AppTextStyles.MetropolisRegular.copyWith(
                color: Colors.red,
                fontSize: 16,
              )),
          content: Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.MetropolisRegular.copyWith(
                color: const Color(0xFF4A4B4D),
                fontSize: 15,
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, cancel deletion
              },
              child: Text("Cancel",
                  style: AppTextStyles.MetropolisRegular.copyWith(
                    color: const Color(0xFF4A4B4D),
                    fontSize: 14,
                  )),
            ),
            TextButton(
              onPressed: () async {
                final result =
                    await addChildrenService.deleteChildrenByParentId(parentId);
                Navigator.of(context).pop(false); // No, cancel deletion

                // Yes, proceed with deletion
              },
              child: Text("Continue",
                  style: AppTextStyles.MetropolisRegular.copyWith(
                    color: Colors.red,
                    fontSize: 14,
                  )),
            ),
          ],
        );
      },
    );
  }
}
