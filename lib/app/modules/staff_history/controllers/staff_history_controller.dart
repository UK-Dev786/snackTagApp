import 'package:get/get.dart';

class StaffHistoryController extends GetxController {
   // Reactive variable for the selected index
  var selectedIndex = 0.obs;

  // Method to update the selected index
  void updateSelectedIndex(int index) {
    print(" msdkhvud $index");
    selectedIndex.value = index;
  }
}
