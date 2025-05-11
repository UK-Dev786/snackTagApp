import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafeteria_setting_history_service.dart';

class CafeteriaSettingHistoryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CafeteriaSettingHistoryService _historyService =
      CafeteriaSettingHistoryService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedIndex = 0.obs;
  var orderHistory = <ParentsAddChildren>[].obs;

  // Add a filter date property that defaults to the current month
  final Rx<DateTime> filterDate = DateTime.now().obs;

  // Map to store orders grouped by date
  final Rx<Map<String, List<ParentsAddChildren>>> groupedOrders =
      Rx<Map<String, List<ParentsAddChildren>>>({});

  @override
  void onInit() {
    super.onInit();
    print("CafeteriaSettingHistoryController initialized");
    fetchHistoryData();
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
    update();
  }

  // Helper method to get relative date string
  String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    print(
        "📅 Date comparison - Date to check: $dateToCheck, Today: $today, Yesterday: $yesterday");

    // Compare dates by comparing their milliseconds since epoch to ensure accurate comparison
    if (dateToCheck.millisecondsSinceEpoch == today.millisecondsSinceEpoch) {
      return 'Today';
    } else if (dateToCheck.millisecondsSinceEpoch ==
        yesterday.millisecondsSinceEpoch) {
      return 'Yesterday';
    } else if (dateToCheck.millisecondsSinceEpoch ==
        twoDaysAgo.millisecondsSinceEpoch) {
      return 'Two days ago';
    } else {
      return DateFormat('EEEE, MMMM d, y')
          .format(date); // e.g., "Monday, May 15, 2023"
    }
  }

  // Group orders by date
  void groupOrdersByDate(List<ParentsAddChildren> orders) {
    final Map<String, List<ParentsAddChildren>> grouped = {};

    for (var order in orders) {
      // Parse the date from the order
      DateTime orderDate;
      if (order.orderPreparationDate != null &&
          order.orderPreparationDate!.isNotEmpty) {
        try {
          // Try to parse the ISO date string
          orderDate = DateTime.parse(order.orderPreparationDate!);
          print(
              "📅 Successfully parsed date: ${order.orderPreparationDate} -> $orderDate");
        } catch (e) {
          print(
              "❌ Error parsing date: ${order.orderPreparationDate}, Error: $e");
          // Default to today if date parsing fails
          orderDate = DateTime.now();
        }
      } else if (order.date != null && order.date!.isNotEmpty) {
        // Try using the 'date' field as fallback
        try {
          orderDate = DateTime.parse(order.date!);
          print("📅 Using fallback date field: ${order.date} -> $orderDate");
        } catch (e) {
          print("❌ Error parsing fallback date: ${order.date}, Error: $e");
          orderDate = DateTime.now();
        }
      } else {
        // Default to today if no date is available
        orderDate = DateTime.now();
        print("⚠️ No date available for order, using current date");
      }

      // Get the relative date string (Today, Yesterday, etc.)
      final dateString = getRelativeDateString(orderDate);
      print("🏷️ Order assigned to date group: $dateString");

      // Add to the appropriate group
      if (!grouped.containsKey(dateString)) {
        grouped[dateString] = [];
      }
      grouped[dateString]!.add(order);
    }

    // Sort the date groups to ensure they appear in chronological order
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        // Put "Today", "Yesterday", "Two days ago" at the top in that order
        final aValue = _getDateGroupSortValue(a);
        final bValue = _getDateGroupSortValue(b);
        return aValue.compareTo(bValue);
      });

    // Create a new map with the sorted keys
    final sortedGroups = <String, List<ParentsAddChildren>>{};
    for (var key in sortedKeys) {
      sortedGroups[key] = grouped[key]!;
    }

    // Sort each group by time (most recent first)
    for (var dateString in sortedGroups.keys) {
      sortedGroups[dateString]!.sort((a, b) {
        DateTime aDate, bDate;

        try {
          aDate = a.orderPreparationDate != null &&
                  a.orderPreparationDate!.isNotEmpty
              ? DateTime.parse(a.orderPreparationDate!)
              : DateTime.now();
        } catch (e) {
          aDate = DateTime.now();
        }

        try {
          bDate = b.orderPreparationDate != null &&
                  b.orderPreparationDate!.isNotEmpty
              ? DateTime.parse(b.orderPreparationDate!)
              : DateTime.now();
        } catch (e) {
          bDate = DateTime.now();
        }

        return bDate.compareTo(aDate); // Descending order (newest first)
      });
    }

    // Update the observable map
    groupedOrders.value = sortedGroups;
    print(
        "📊 Grouped orders into ${sortedGroups.length} date groups: ${sortedGroups.keys.join(', ')}");
  }

  // Helper method to get sort value for date groups
  int _getDateGroupSortValue(String dateGroup) {
    if (dateGroup == 'Today') return 0;
    if (dateGroup == 'Yesterday') return 1;
    if (dateGroup == 'Two days ago') return 2;
    // For other dates, they'll be sorted alphabetically after the special cases
    return 3;
  }

  Future<void> fetchHistoryData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current user ID
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      print("🔍 Fetching history data for user ID: $userId");

      // Fetch order history from service
      final orders = await _historyService.fetchOrderHistory(userId);

      // Update the observable list
      orderHistory.assignAll(orders);

      // Group orders by date
      groupOrdersByDate(orders);

      print("📋 Fetched ${orders.length} orders successfully");

      // If no orders were found, set a more user-friendly error message
      if (orders.isEmpty) {
        print("ℹ️ No orders found for this cafeteria admin");
      }
    } catch (e) {
      errorMessage.value = 'Error fetching history data: $e';
      print("❌ Error in fetchHistoryData: $e");
    } finally {
      isLoading.value = false;
      update(['cafeteriaHistoryId']);
    }
  }

  // Method to update the filter date
  void updateFilterDate(DateTime newDate) {
    filterDate.value = newDate;
    // Optionally refresh the data based on the new date
    // fetchHistoryData();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
