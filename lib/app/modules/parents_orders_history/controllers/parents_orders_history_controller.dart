import 'package:get/get.dart';
import 'package:snacktag/models/notification_model.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ParentsOrdersHistoryController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print("ParentsOrdersHistory: Starting to fetch order history");
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      print("ParentsOrdersHistory: Using userId: $userId");

      // Force refresh notifications from Firestore
      await _notificationService.refreshNotifications(userId);

      _notificationService.getNotifications(userId).listen((notificationsList) {
        print(
            "ParentsOrdersHistory: Received ${notificationsList.length} notifications");

        // Check if we have any notifications from today
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        print(
            "ParentsOrdersHistory: Today's date: ${DateFormat('yyyy-MM-dd').format(today)}");

        // Log all notifications for debugging
        print("ParentsOrdersHistory: All notifications:");
        for (var notification in notificationsList.take(10)) {
          print("-----------------------------------");
          print("ID: ${notification.id}");
          print("Type: ${notification.type}");
          print("Title: ${notification.title}");
          print("Body: ${notification.body}");
          print(
              "Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.timestamp)}");
          print("Data: ${notification.data}");
          print("-----------------------------------");
        }

        final todayNotifications = notificationsList.where((notification) {
          final notificationDate = DateTime(
            notification.timestamp.year,
            notification.timestamp.month,
            notification.timestamp.day,
          );
          final isToday = notificationDate.isAtSameMomentAs(today);
          print(
              "ParentsOrdersHistory: Notification date: ${DateFormat('yyyy-MM-dd').format(notificationDate)}, isToday: $isToday");
          return isToday;
        }).toList();

        print(
            "ParentsOrdersHistory: Found ${todayNotifications.length} notifications from today");

        // Log today's notifications for debugging
        print("ParentsOrdersHistory: Today's notifications:");
        for (var notification in todayNotifications) {
          print("-----------------------------------");
          print("ID: ${notification.id}");
          print("Type: ${notification.type}");
          print("Title: ${notification.title}");
          print("Body: ${notification.body}");
          print(
              "Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.timestamp)}");
          print("Data: ${notification.data}");
          print("-----------------------------------");
        }

        // Filter only delivered order notifications - expanded criteria
        final deliveredOrders = notificationsList
            .where((notification) =>
                notification.type == 'order_delivered' ||
                notification.title.toLowerCase().contains('delivered') ||
                notification.body.toLowerCase().contains('delivered') ||
                notification.title.toLowerCase().contains('delivery') ||
                notification.body.toLowerCase().contains('delivery'))
            .toList();

        print(
            "ParentsOrdersHistory: Filtered to ${deliveredOrders.length} delivered orders");

        // Debug timestamps to check if we have today's orders
        print("ParentsOrdersHistory: Delivered orders details:");
        for (var order in deliveredOrders) {
          print("-----------------------------------");
          print("ID: ${order.id}");
          print("Type: ${order.type}");
          print("Title: ${order.title}");
          print("Body: ${order.body}");
          print(
              "Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(order.timestamp)}");
          print("Data: ${order.data}");
          print("-----------------------------------");
        }

        // Check specifically for today's delivered orders
        final todayDeliveredOrders = deliveredOrders.where((notification) {
          final notificationDate = DateTime(
            notification.timestamp.year,
            notification.timestamp.month,
            notification.timestamp.day,
          );
          return notificationDate.year == today.year &&
              notificationDate.month == today.month &&
              notificationDate.day == today.day;
        }).toList();

        print(
            "ParentsOrdersHistory: Found ${todayDeliveredOrders.length} delivered orders from today");

        // Sort by timestamp (newest first)
        deliveredOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        notifications.value = deliveredOrders;
        count.value = deliveredOrders.length;
        print(
            "ParentsOrdersHistory: Updated notifications count: ${count.value}");

        isLoading.value = false;
      }, onError: (error) {
        print("ParentsOrdersHistory: Error in stream: $error");
        errorMessage.value = 'Failed to load order history: $error';
        isLoading.value = false;
      }, onDone: () {
        print("ParentsOrdersHistory: Stream completed");
        isLoading.value = false;
      });
    } catch (e) {
      print("ParentsOrdersHistory: Exception caught: $e");
      errorMessage.value = 'Failed to load order history: $e';
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      if (notifications.isNotEmpty) {
        await _notificationService.deleteNotification(
            notifications.first.userId, notificationId);
        notifications.removeWhere((n) => n.id == notificationId);
        count.value = notifications.length;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete notification: $e';
    }
  }

  // Add a method to manually refresh notifications
  Future<void> refreshOrderHistory() async {
    try {
      print("ParentsOrdersHistory: Manually refreshing order history");
      isLoading.value = true;

      // Clear any error messages
      errorMessage.value = '';

      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Force refresh from Firestore
      await _notificationService.refreshNotifications(userId);

      // Fetch again
      await fetchOrderHistory();

      // Show a snackbar to confirm refresh
      Get.snackbar(
        'Refreshed',
        'Order history has been refreshed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("ParentsOrdersHistory: Error refreshing order history: $e");
      errorMessage.value = 'Failed to refresh order history: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
