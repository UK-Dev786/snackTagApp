import 'package:get/get.dart';

import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/staff_services/staff_history_calendar_service.dart';

class StaffHistoryDetailController extends GetxController {
  final StaffHistoryCalendarService cafaterisHistorySelectDateService =
      StaffHistoryCalendarService();
  //TODO: Implement CafeteriaHistoryDetailsController
  List<String>? orderStudentIds;
  String? mealName;
  var isLoading = false.obs;
  var childrenList = <ParentsAddChildren>[].obs;
  var errorMessage = ''.obs;

  final count = 0.obs;
  @override
  void onInit() {
    print("CafeteriaHistoryDetailsController onInit called");
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      print("Arguments received: ${Get.arguments}");

      // Extract student IDs from arguments
      var studentIdsArg = Get.arguments["orderStudentIds"];
      print("Raw Student IDs from arguments: $studentIdsArg");

      // Extract meal name from arguments
      mealName = Get.arguments["mealName"] as String?;
      print("Meal name from arguments: $mealName");

      if (studentIdsArg != null) {
        orderStudentIds = List<String>.from(studentIdsArg);
        print("Processed Student IDs: $orderStudentIds");
        print("Number of student IDs: ${orderStudentIds?.length}");

        if (orderStudentIds?.isNotEmpty ?? false) {
          fetchChildrenData();
        } else {
          errorMessage.value = 'No student IDs provided';
          print("ERROR: Student IDs list is empty");
        }
      } else {
        errorMessage.value = 'No student IDs provided';
        print("ERROR: Student IDs argument is null");
      }
    } else {
      print("No arguments received or invalid format");
      errorMessage.value = 'No data received';
    }
  }
  // Future<void> fetchCafateriaChildren() async {
  //   isLoading.value = true;
  //
  //   List<ParentsAddChildren> children = await cafaterisHistorySelectDateService
  //       .fetchChildrenByCafateriaName(cafateriaAdminName!);
  //   childrenList.assignAll(children);
  //   print("children data is  $children");
  //
  //   isLoading.value = false;
  //   update(['cafateriaHistorySelectDataId']);
  // }

  Future<void> fetchChildrenData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // First, try to fetch children by meal name if available
      if (mealName != null && mealName!.isNotEmpty) {
        print("DEBUG: Fetching children for meal name: $mealName");

        final childrenByMeal = await cafaterisHistorySelectDateService
            .fetchChildrenByMealName(mealName!);

        print(
            "DEBUG: Found ${childrenByMeal.length} children with meal: $mealName");

        if (childrenByMeal.isNotEmpty) {
          childrenList.assignAll(childrenByMeal);
          print(
              "SUCCESS: Fetched ${childrenByMeal.length} children by meal name successfully");

          // Log each child found for debugging
          for (var child in childrenByMeal) {
            print(
                "DEBUG: Found child with meal - Name: ${child.childName}, ID: ${child.id}, School: ${child.schoolName}");
          }
          return;
        } else {
          print(
              "DEBUG: No children found with meal name: $mealName, falling back to student IDs");
        }
      }

      // If meal name search didn't work or no meal name provided, try with student IDs
      if (orderStudentIds == null || orderStudentIds!.isEmpty) {
        errorMessage.value = 'No student IDs to fetch';
        print("ERROR: No student IDs to fetch in fetchChildrenData");
        return;
      }

      print(
          "DEBUG: Fetching children for ${orderStudentIds!.length} student IDs: $orderStudentIds");

      final children = await cafaterisHistorySelectDateService
          .fetchChildrenByIds(orderStudentIds!);

      print("DEBUG: Fetch result - found ${children.length} children");

      if (children.isEmpty) {
        // Check if we have any dummy IDs (starting with "student_")
        List<String> dummyIds =
            orderStudentIds!.where((id) => id.startsWith("student_")).toList();

        if (dummyIds.isNotEmpty) {
          print("INFO: Creating placeholder children for dummy IDs: $dummyIds");

          // Create placeholder children for dummy IDs
          List<ParentsAddChildren> placeholderChildren = [];

          for (int i = 0; i < dummyIds.length; i++) {
            placeholderChildren.add(ParentsAddChildren(
              id: dummyIds[i],
              childName: "Student ${i + 1}",
              childSchoolID: "Placeholder ID",
              schoolName: "Placeholder School",
              childImageUrl: "", // Empty image URL will show default image
            ));
          }

          childrenList.assignAll(placeholderChildren);
          print(
              "SUCCESS: Created ${placeholderChildren.length} placeholder children");
        } else {
          errorMessage.value =
              'No children found for the selected order. The student IDs may not exist in the database.';
          print("ERROR: No children found for student IDs: $orderStudentIds");
        }
      } else {
        childrenList.assignAll(children);
        print("SUCCESS: Fetched ${children.length} children successfully");

        // Log each child found for debugging
        for (var child in children) {
          print(
              "DEBUG: Found child - Name: ${child.childName}, ID: ${child.id}, School: ${child.schoolName}");
        }
      }
    } catch (e) {
      errorMessage.value = 'Error fetching children data: $e';
      print("ERROR in fetchChildrenData: $e");
    } finally {
      isLoading.value = false;
      // Make sure we're using the correct update ID
      update(['staffHistoryDetailId', 'cafeteriaHistoryDetailsId']);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
