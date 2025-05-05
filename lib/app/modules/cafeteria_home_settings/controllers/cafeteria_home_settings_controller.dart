import 'package:get/get.dart';

class CafeteriaHomeSettingsController extends GetxController {
    // Reactive variable for the selected index
  var selectedIndex = 0.obs;

  // Method to update the selected index
  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }
 
}
