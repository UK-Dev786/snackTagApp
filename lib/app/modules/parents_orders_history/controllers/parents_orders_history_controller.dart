import 'package:get/get.dart';
import 'package:snacktag/models/notification_model.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ParentsOrdersHistoryController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final count = 0.obs;

  // Cache for school names to avoid repeated database queries
  final Map<String, String> _schoolNameCache = {};

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

  // Method to get school name for a child from the parentsChildren collection
  Future<String> getSchoolNameForChild(String childId) async {
    // Check cache first
    if (_schoolNameCache.containsKey(childId)) {
      return _schoolNameCache[childId]!;
    }

    try {
      // Try to find the document by querying for the childId field
      QuerySnapshot querySnapshot = await _firestore
          .collection('parentsChildren')
          .where('childId', isEqualTo: childId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract school name from the document
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final schoolName = data['schoolName'] as String?;

        if (schoolName != null && schoolName.isNotEmpty) {
          // Cache the result
          _schoolNameCache[childId] = schoolName;
          return schoolName;
        }
      }

      // If we couldn't find by childId, try direct document reference
      DocumentSnapshot childDoc =
          await _firestore.collection('parentsChildren').doc(childId).get();

      if (childDoc.exists) {
        final data = childDoc.data() as Map<String, dynamic>;
        final schoolName = data['schoolName'] as String?;

        if (schoolName != null && schoolName.isNotEmpty) {
          // Cache the result
          _schoolNameCache[childId] = schoolName;
          return schoolName;
        }
      }

      return "School information unavailable";
    } catch (e) {
      print("Error fetching school name for child: $e");
      return "School information unavailable";
    }
  }

  // Method to get school name from notification data or database
  Future<String> getSchoolNameForNotification(
      NotificationModel notification) async {
    // Try to get school name directly from notification data
    if (notification.data.containsKey('schoolName') &&
        notification.data['schoolName'] != null &&
        notification.data['schoolName'].toString().isNotEmpty) {
      return notification.data['schoolName'].toString();
    }

    // Try to get cafeteria name from notification data
    if (notification.data.containsKey('cafeteriaName') &&
        notification.data['cafeteriaName'] != null &&
        notification.data['cafeteriaName'].toString().isNotEmpty) {
      return notification.data['cafeteriaName'].toString();
    }

    // Try to get child ID from notification data
    String? childId;
    if (notification.data.containsKey('childId') &&
        notification.data['childId'] != null &&
        notification.data['childId'].toString().isNotEmpty) {
      childId = notification.data['childId'].toString();
    }

    // If we have a child ID, try to get school name from database
    if (childId != null) {
      return await getSchoolNameForChild(childId);
    }

    // Try to get order ID from notification data
    String? orderId;
    if (notification.data.containsKey('orderId') &&
        notification.data['orderId'] != null &&
        notification.data['orderId'].toString().isNotEmpty) {
      orderId = notification.data['orderId'].toString();

      // Try to get order details from database
      try {
        DocumentSnapshot orderDoc =
            await _firestore.collection('orderPreparation').doc(orderId).get();

        if (orderDoc.exists) {
          final data = orderDoc.data() as Map<String, dynamic>;

          // Try to get school name from order
          final schoolName = data['schoolName'] as String?;
          if (schoolName != null && schoolName.isNotEmpty) {
            return schoolName;
          }

          // Try to get cafeteria name from order
          final cafeteriaName = data['cafeteriaName'] as String?;
          if (cafeteriaName != null && cafeteriaName.isNotEmpty) {
            return cafeteriaName;
          }

          // Try to get child ID from order and then get school name
          final childIdFromOrder = data['childId'] as String?;
          if (childIdFromOrder != null && childIdFromOrder.isNotEmpty) {
            return await getSchoolNameForChild(childIdFromOrder);
          }
        }
      } catch (e) {
        print("Error fetching order details: $e");
      }
    }

    // If all else fails, return a generic message
    return "School information unavailable";
  }

  Future<String> getMealPriceForNotification(
      NotificationModel notification) async {
    try {
      // Get the orderId from the notification data
      final orderId = notification.data['orderId'];
      if (orderId == null || orderId.isEmpty) {
        return '0.00';
      }

      // Fetch the order from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('orderPreparation')
          .doc(orderId)
          .get();

      if (!doc.exists) {
        return '0.00';
      }

      // Extract the meal price from the order data
      final data = doc.data();
      if (data != null &&
          data.containsKey('selectedMealMenuData') &&
          data['selectedMealMenuData'] is List &&
          data['selectedMealMenuData'].isNotEmpty) {
        final mealData = data['selectedMealMenuData'][0];
        if (mealData != null && mealData.containsKey('mealPrice')) {
          return mealData['mealPrice'].toString();
        }
      }

      return '0.00';
    } catch (e) {
      print('Error fetching meal price: $e');
      return '0.00';
    }
  }
}
