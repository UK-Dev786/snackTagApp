import 'package:get/get.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_selected_meals.dart';

class StaffOrderDetailsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  // Data for the order details
  var orderData = Rx<Map<String, dynamic>?>(null);
  var timeSlots = <String>['10:00', '12:00', '15:00'].obs;
  var selectedTimeSlot = '10:00'.obs;
  
  // Food items with calories for each time slot
  var foodItemsData = Rx<Map<String, List<Map<String, dynamic>>>?>({
    '10:00': [
      {'name': 'Molletes', 'calories': '16 calorías'},
      {'name': 'Pancakes', 'calories': '28 calorías'},
      {'name': 'Sincronizada', 'calories': '19 calorías'},
      {'name': 'Quesadilla', 'calories': '41 calorías'},
      {'name': 'Cesar Juice', 'calories': '23 calorías'},
    ],
    '12:00': [
      {'name': 'Molletes', 'calories': '27 calorías'},
      {'name': 'Sincronizada', 'calories': '31 calorías'},
      {'name': 'Quesadilla', 'calories': '17 calorías'},
      {'name': 'Cesar Juice', 'calories': '41 calorías'},
    ],
    '15:00': [
      {'name': 'Molletes', 'calories': '18 calorías'},
      {'name': 'Chicken Tacos', 'calories': '21 calorías'},
      {'name': 'Cesar Juice', 'calories': '19 calorías'},
    ],
  });

  @override
  void onInit() {
    super.onInit();
    // Get arguments if any
    if (Get.arguments != null) {
      orderData.value = Get.arguments;
      print('Order data received: ${orderData.value}');
    }
  }

  // Method to change the selected time slot
  void changeTimeSlot(String timeSlot) {
    selectedTimeSlot.value = timeSlot;
  }

  // Method to navigate to previous time slot
  void goToPreviousTimeSlot() {
    int currentIndex = timeSlots.indexOf(selectedTimeSlot.value);
    if (currentIndex > 0) {
      selectedTimeSlot.value = timeSlots[currentIndex - 1];
    }
  }

  // Method to navigate to next time slot
  void goToNextTimeSlot() {
    int currentIndex = timeSlots.indexOf(selectedTimeSlot.value);
    if (currentIndex < timeSlots.length - 1) {
      selectedTimeSlot.value = timeSlots[currentIndex + 1];
    }
  }

  // Method to go back to calendar
  void goBackToCalendar() {
    Get.back();
  }
}
