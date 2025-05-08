import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/app/modules/staff_history_list/controllers/staff_history_list_controller.dart';

class StaffOrderHistoryController extends GetxController {
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxString currentMonthYear = ''.obs;

  @override
  void onInit() {
    super.onInit();
    updateMonthYearText();

    // Initial refresh of the history list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshHistoryList();
    });
  }

  void updateMonthYearText() {
    currentMonthYear.value =
        DateFormat('MMMM yyyy').format(selectedMonth.value);
  }

  void nextMonth() {
    // Move to next month
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      1,
    );
    updateMonthYearText();
    // Trigger refresh of the history list
    refreshHistoryList();
  }

  void previousMonth() {
    // Move to previous month
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
      1,
    );
    updateMonthYearText();
    // Trigger refresh of the history list
    refreshHistoryList();
  }

  void refreshHistoryList() {
    // Get the StaffHistoryListController and refresh its data
    if (Get.isRegistered<StaffHistoryListController>()) {
      final historyListController = Get.find<StaffHistoryListController>();
      historyListController.fetchDeliveredOrdersForMonth(
          selectedMonth.value.year, selectedMonth.value.month);
    } else {
      print("⚠️ StaffHistoryListController is not registered");
    }
  }
}
