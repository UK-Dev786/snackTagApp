import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/parents/parent_upcoming_detail_service.dart';

class ParentUpcomingOrderDetailController extends GetxController {
  final ParentsUpcomingDetailService parentsUpcomingDetailService =
      ParentsUpcomingDetailService();
  List<String>? studentIds;
  String? mealName;
  var isLoading = false.obs;
  var childrenList = <ParentsAddChildren>[].obs;
  var errorMessage = ''.obs;

  final count = 0.obs;

  @override
  void onInit() {
    print("ParentUpcomingOrderDetailController onInit called");
    super.onInit();

    final args = Get.arguments;
    print('Arguments received: $args');

    if (args != null && args is Map<String, dynamic>) {
      // Get the student IDs for this specific order
      var rawStudentIds = args['orderStudentIds'];
      print(
          'Raw student IDs: $rawStudentIds (type: ${rawStudentIds.runtimeType})');

      // Get the meal name if available
      mealName = args['mealName'] as String?;
      print('Meal name: $mealName');

      if (rawStudentIds == null) {
        print('orderStudentIds is null in arguments');
        errorMessage.value = 'No student IDs provided in arguments';
        return;
      }

      try {
        studentIds = List<String>.from(rawStudentIds);
        print(
            'Processed student IDs: $studentIds (type: ${studentIds.runtimeType})');
        print('Student IDs count: ${studentIds!.length}');

        if (studentIds!.isEmpty) {
          print('Student IDs list is empty');
          errorMessage.value = 'No student IDs found in the order';
          return;
        }

        fetchChildrenData();
      } catch (e) {
        print('Error processing student IDs: $e');
        errorMessage.value = 'Error processing student IDs: $e';
      }
    } else {
      print('No arguments received or invalid format');
      errorMessage.value = 'No student IDs provided';
    }
  }

  Future<void> fetchChildrenData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print(
          'Fetching children for order with IDs: $studentIds and meal: $mealName');

      if (studentIds == null || studentIds!.isEmpty) {
        errorMessage.value = 'No student IDs to fetch';
        return;
      }

      // Use the improved method to fetch only children related to this specific order
      // Pass the meal name to filter by meal
      final children = await parentsUpcomingDetailService
          .fetchChildrenForOrder(studentIds, mealName: mealName);

      if (children.isEmpty) {
        errorMessage.value = 'No children found for this order';
      } else {
        // Make sure we only show the children that are actually part of this order
        childrenList.assignAll(children);
        print(
            "Fetched ${children.length} children for this order successfully");

        if (mealName != null) {
          print("Order is for meal: $mealName");
        }
      }
    } catch (e) {
      errorMessage.value = 'Error fetching children data: $e';
      print("Error in fetchChildrenData: $e");
    } finally {
      isLoading.value = false;
      update(['parentUpcomingOrderDetailId']);
    }
  }
}
