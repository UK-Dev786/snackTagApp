import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/parents/parent_upcoming_detail_service.dart';

class ParentUpcomingOrderDetailController extends GetxController {
  final ParentsUpcomingDetailService parentsUpcomingDetailService = ParentsUpcomingDetailService();
  List<String>? studentIds;
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
      print('Processing student IDs: $studentIds');
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
      print('Fetching children for IDs: $studentIds');

      if (studentIds == null || studentIds!.isEmpty) {
        errorMessage.value = 'No student IDs to fetch';
        return;
      }

      final children = await parentsUpcomingDetailService.fetchChildrenByIds(studentIds!);

      if (children.isEmpty) {
        errorMessage.value = 'No children found';
      } else {
        childrenList.assignAll(children);
        print("Fetched ${children.length} children successfully");
      }
    } catch (e) {
      errorMessage.value = 'Error fetching children data: $e';
      print("Error in fetchChildrenData: $e");
    } finally {
      isLoading.value = false;
      update(['cafeteriaHistoryDetailsId']);
    }
  }

}