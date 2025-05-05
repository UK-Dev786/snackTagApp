import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/parents/add_children_service.dart';

class CafeteriaController extends GetxController {
  final AddChildrenService addChildrenService = AddChildrenService();

  //TODO: Implement CafeteriaController

  var selectedIndexes = <int>{}.obs;
var  cafeteriaL = <UserModel>[].obs;
  var filteredCafeteriaL = <UserModel>[].obs;

  var schoolName = ''.obs; // Store the school name
  var childName = ''.obs; // Store the school name
  var childId = ''.obs; // Store the school name
  TextEditingController searchTextController = TextEditingController();
  var isLoading = false.obs;
  var isDataFound = false.obs;
  var searchText = "".obs;
  bool isEdit = false;


  final TextEditingController textController = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      schoolName.value = Get.arguments;
      childName.value = Get.arguments;
   }

    fetchSchoolCafeteria();
  }

  void fetchSchoolCafeteria() async {
    isLoading.value = true;

    // Ensure getCafeteriaSchool returns a Stream
    cafeteriaL.bindStream(addChildrenService.getCafeteriaSchool(schoolName.value));

    cafeteriaL.listen((_) {
      print("Fetched School Data: $cafeteriaL");
      filterCafeteria();
      isLoading.value = false; // Set loading to false only after data loads
    });
  }

  void filterCafeteria() {
    if (searchText.value.isEmpty) {
      filteredCafeteriaL.assignAll(cafeteriaL);
      isDataFound.value = false;
    } else {
      filteredCafeteriaL.assignAll(
          cafeteriaL.where((cafeteria) =>
          (cafeteria.cafeteriaName?.toLowerCase().contains(searchText.value.toLowerCase()) ?? false)
          )
      );
      isDataFound.value = filteredCafeteriaL.isEmpty;
    }
  }

//
//   void fetchSchoolCafeteria() async {
//     isLoading.value = true;
//     // cafeteriaList.value = await addChildrenService.getCafeteriaSchool(schoolName.value);
//     // schoolNamesList.assignAll(schools);
//     // convertToUserModel(); // Convert after fetching
//     cafeteriaL.bindStream(addChildrenService.getCafeteriaSchool(schoolName.value));
//
//     // Print the fetched list
//     print("Fetched School Data is : ");
//     filterCafeteria();
//
//     isLoading.value = false;
//   }
//
//
//   void filterCafeteria() {
//     print("yws");
//     if (searchText.value.isEmpty) {
//       print("yes");
//
//       filteredCafeteriaL.assignAll(cafeteriaL);
//       isDataFound.value = false;
//     } else {
//       print("no");
//
//       filteredCafeteriaL.assignAll(cafeteriaL.where((cafeteria) => cafeteria.cafeteriaName!.toLowerCase().contains(searchText.value.toLowerCase())));
//       isDataFound.value = filteredCafeteriaL.isEmpty;
//     }
// }
  void updateSearchText(String text) {
    searchText.value = text;
    filterCafeteria();
  }
}
