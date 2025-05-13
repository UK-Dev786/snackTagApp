import 'package:get/get.dart';

import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafeteria_upcoming_detail_service.dart';
import 'package:snacktag/services/staff_services/staff_history_calendar_service.dart';

class CafeteriaUpcomingDetailsController extends GetxController {
  final CafeteriaUpcomingDetailService cafeteriaUpcomingDetailService =
      CafeteriaUpcomingDetailService();
  List<String>? studentIds;
  String? mealName;
  var isLoading = false.obs;
  var childrenList = <ParentsAddChildren>[].obs;
  var errorMessage = ''.obs;

  final count = 0.obs;

  @override
  void onInit() {
    print("CafeteriaUpcomingDetailsController onInit called");
    super.onInit();

    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      studentIds = List<String>.from(args['orderStudentIds'] ?? []);
      mealName = args['mealName'] as String?;

      print('Processing student IDs: $studentIds');
      print('Meal name: $mealName');

      fetchChildrenData();
    } else {
      print('No arguments received or invalid format');
      errorMessage.value = 'No student IDs provided';
    }
  }

  Future<void> fetchChildrenData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('Fetching children for IDs: $studentIds, meal name: $mealName');

      if (studentIds == null || studentIds!.isEmpty) {
        errorMessage.value = 'No student IDs to fetch';
        return;
      }

      // First fetch all children by IDs
      final allChildren =
          await cafeteriaUpcomingDetailService.fetchChildrenByIds(studentIds!);

      if (allChildren.isEmpty) {
        errorMessage.value = 'No children found';
        return;
      }

      print("Fetched ${allChildren.length} children successfully");

      // If meal name is provided, filter children by meal name
      if (mealName != null && mealName!.isNotEmpty) {
        print("Filtering children by meal name: $mealName");

        // Filter children that have the specified meal in their selectedMealMenuData
        final filteredChildren = allChildren.where((child) {
          if (child.selectedMealMenuData == null ||
              child.selectedMealMenuData!.isEmpty) {
            return false;
          }

          // Check if any meal in selectedMealMenuData matches the meal name
          return child.selectedMealMenuData!
              .any((meal) => meal.mealName == mealName);
        }).toList();

        if (filteredChildren.isEmpty) {
          print("No children found with meal: $mealName");
          errorMessage.value = 'No children found with the selected meal';
        } else {
          print(
              "Found ${filteredChildren.length} children with meal: $mealName");
          childrenList.assignAll(filteredChildren);
        }
      } else {
        // If no meal name is provided, use all children
        childrenList.assignAll(allChildren);
      }
    } catch (e) {
      errorMessage.value = 'Error fetching children data: $e';
      print("Error in fetchChildrenData: $e");
    } finally {
      isLoading.value = false;
      update(['cafeteriaHistoryDetailsId']);
    }
  }

  void increment() => count.value++;
}
