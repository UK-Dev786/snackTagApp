import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/notification_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final UserPreferences _userPreferences = UserPreferences();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;

  // We'll set this in onInit after checking for staff login
  final RxString userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _getUserId();

    // Check if notifications exist in Firestore after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      _checkNotificationsExist();
    });
  }

  // Get the correct user ID based on login type (regular user or staff)
  Future<void> _getUserId() async {
    try {
      // First try to get the staff data from preferences
      final staffData = await _userPreferences.getStaffDataPreference();

      if (staffData != null &&
          staffData.id != null &&
          staffData.id!.isNotEmpty) {
        // This is a staff user, use the staff ID
        print("📱 Using staff ID for notifications: ${staffData.id}");
        userId.value = staffData.id!;

        // Debug: Print all staff data to verify
        print("📱 Staff data details:");
        print("   ID: ${staffData.id}");
        print("   Name: ${staffData.staffName}");
        print("   Email: ${staffData.staffEmail}");
        print("   Phone: ${staffData.staffPhone}");
        print("   User ID: ${staffData.userId}");

        // Make sure FCM token is updated for this staff
        await _notificationService.updateFCMTokenForStaff(staffData.id!);
      } else {
        // This is a regular user, use Firebase Auth UID
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          print(
              "📱 Using Firebase Auth UID for notifications: ${firebaseUser.uid}");
          userId.value = firebaseUser.uid;
        } else {
          // Fallback to stored user ID in preferences
          final storedUserId = await _userPreferences.getUserId();
          if (storedUserId != null && storedUserId.isNotEmpty) {
            print("📱 Using stored user ID for notifications: $storedUserId");
            userId.value = storedUserId;
          } else {
            print("⚠️ No user ID found for notifications");
            userId.value = "";
          }
        }
      }

      // Once we have the user ID, start listening for notifications
      if (userId.value.isNotEmpty) {
        _listenToNotifications();

        // Force check for notifications after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          _checkNotificationsExist();
        });
      }
    } catch (e) {
      print("❌ Error getting user ID: $e");
      userId.value = "";
    }
  }

  // Method to check if notifications exist in Firestore
  Future<void> _checkNotificationsExist() async {
    try {
      if (userId.value.isEmpty) {
        print("🚫 Cannot check notifications: userId is empty");
        return;
      }

      print("🔍 Checking if notifications exist for user: ${userId.value}");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId.value)
          .collection('notifications')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print(
            "⚠️ No notifications found in Firestore for user: ${userId.value}");

        // Show a snackbar to inform the user
        Get.snackbar(
          'No Notifications',
          'You don\'t have any notifications yet.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } else {
        print("✅ Found notifications in Firestore for user: ${userId.value}");
      }
    } catch (e) {
      print("❌ Error checking notifications: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      isLoading.value = true;
      await _notificationService.initialize();
    } catch (e) {
      errorMessage.value = 'Failed to initialize notifications: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToNotifications() {
    if (userId.value.isEmpty) {
      print("🚫 Cannot listen to notifications: userId is empty");
      return;
    }

    print("🔔 Starting to listen to notifications for userId: ${userId.value}");
    print("🔍 Firestore path: users/${userId.value}/notifications");

    _notificationService.getNotifications(userId.value).listen(
      (notificationsList) {
        print("📬 Received ${notificationsList.length} notifications");

        // CRITICAL FIX: Filter out duplicate notifications by title and body
        final Map<String, NotificationModel> uniqueNotifications = {};

        for (var notification in notificationsList) {
          // Create a unique key based on title and body
          final String key = "${notification.title}|${notification.body}";

          // Only keep the first notification with this title and body
          if (!uniqueNotifications.containsKey(key)) {
            uniqueNotifications[key] = notification;
          }
        }

        // Convert back to list and sort by timestamp (newest first)
        final List<NotificationModel> filteredList = uniqueNotifications.values
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        print(
            "📊 Filtered from ${notificationsList.length} to ${filteredList.length} unique notifications");

        // Update the notifications list with the filtered list
        notifications.value = filteredList;
        _updateUnreadCount();
        print("📊 Updated unread count: ${unreadCount.value}");

        // Debug: Print all notification details
        if (filteredList.isEmpty) {
          print(
              "⚠️ No notifications found in Firestore for user: ${userId.value}");
        } else {
          print("✅ Found ${filteredList.length} unique notifications");
          for (var notification in filteredList) {
            print("📌 Notification: ${notification.id}");
            print("   Title: ${notification.title}");
            print("   Body: ${notification.body}");
          }
        }

        // Force UI refresh
        notifications.refresh();
      },
      onError: (error) {
        print("❌ Error listening to notifications: $error");
        errorMessage.value = 'Failed to fetch notifications: $error';
      },
    );
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(userId.value, notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          userId: notifications[index].userId,
          title: notifications[index].title,
          body: notifications[index].body,
          type: notifications[index].type,
          data: notifications[index].data,
          timestamp: notifications[index].timestamp,
          isRead: true,
        );
        notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      errorMessage.value = 'Failed to mark notification as read: $e';
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      final batch = FirebaseFirestore.instance.batch();

      for (var notification in notifications.where((n) => !n.isRead)) {
        final ref = FirebaseFirestore.instance
            .collection('users')
            .doc(userId.value)
            .collection('notifications')
            .doc(notification.id);
        batch.update(ref, {'isRead': true});
      }

      await batch.commit();

      notifications.value = notifications
          .map((n) => NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                type: n.type,
                data: n.data,
                timestamp: n.timestamp,
                isRead: true,
              ))
          .toList();
      unreadCount.value = 0;
    } catch (e) {
      errorMessage.value = 'Failed to mark all notifications as read: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(
          userId.value, notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      errorMessage.value = 'Failed to delete notification: $e';
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      isLoading.value = true;
      await _notificationService.clearAllNotifications();
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      errorMessage.value = 'Failed to clear notifications: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Method to manually refresh notifications
  Future<void> refreshNotifications() async {
    try {
      print("🔄 Manually refreshing notifications");
      isLoading.value = true;

      // Clear any error messages
      errorMessage.value = '';

      // Check if notifications exist
      await _checkNotificationsExist();

      // Force refresh the UI
      notifications.refresh();

      // Show a snackbar to confirm refresh
      Get.snackbar(
        'Refreshed',
        'Notifications have been refreshed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("❌ Error refreshing notifications: $e");
      errorMessage.value = 'Failed to refresh notifications: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleNotificationTap(NotificationModel notification) async {
    try {
      await markAsRead(notification.id);

      switch (notification.type) {
        case 'order_prepared':
          print(
              "🔄 Navigating to order details with ID: ${notification.data['orderId']}");
          Get.toNamed('/order-details',
              arguments: notification.data['orderId']);
          break;
        case 'order_delivered':
          print(
              "🔄 Navigating to order history with ID: ${notification.data['orderId']}");

          // Check if this is a cafe owner notification by checking the user type
          final firebaseUser = FirebaseAuth.instance.currentUser;
          String userType = '';

          if (firebaseUser != null) {
            try {
              // Get user document from Firestore
              DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
                  .collection('users')
                  .doc(firebaseUser.uid)
                  .get();

              if (userDoc.exists && userDoc.data() != null) {
                userType = userDoc.data()?['role'] ?? '';
                print("User role for notification handling: $userType");
              }
            } catch (e) {
              print("Error getting user role: $e");
            }
          }

          if (userType == 'cafeteriaAdmin') {
            // This is a cafe owner, navigate to the cafe owner order delivery details
            print(
                "🔄 Cafe owner notification - navigating to cafe owner order delivery details");
            Get.toNamed(
              '/cafe-owner-order-delivery-details',
              arguments: {
                'orderId': notification.data['orderId'],
                'staffName': notification.data['deliveredBy'] ?? 'Staff',
                'childName': notification.data['childName'] ?? 'Student',
                'amount': notification.data['amount'] ?? '0.00',
              },
            );
          } else {
            // This is a parent, navigate to the parent order delivery details
            print(
                "🔄 Parent notification - navigating to parent order delivery details");
            Get.toNamed(
              '/parent-order-delivery-details',
              arguments: {
                'orderId': notification.data['orderId'],
                'staffName': notification.data['deliveredBy'] ?? 'Staff',
                'childName': notification.data['childName'] ?? 'Student',
              },
            );
          }
          break;
        case 'new_order':
          print(
              "🔄 Navigating to order details with ID: ${notification.data['orderId']}");
          Get.toNamed('/order-details',
              arguments: notification.data['orderId']);
          break;
        case 'low_balance':
          print(
              "🔄 Navigating to wallet with required amount: ${notification.data['requiredAmount']}");
          Get.toNamed('/wallet', arguments: {
            'showTopUp': true,
            'requiredAmount': notification.data['requiredAmount'] ?? 0,
          });
          break;
        case 'new_message':
          print(
              "🔄 Navigating to chat with ID: ${notification.data['chatId']}");
          Get.toNamed('/chat', arguments: notification.data['chatId']);
          break;
        default:
          // Handle unknown notification types
          print("⚠️ Unknown notification type: ${notification.type}");
          // Navigate to notifications view as fallback
          Get.toNamed('/notifications');
      }
    } catch (e) {
      errorMessage.value = 'Failed to handle notification: $e';
    }
  }

  // Method to send notification when order is prepared
  Future<void> sendOrderPreparedNotification({
    required String parentId,
    required String orderId,
    required String childName,
    required String preparedBy,
    String? childImageUrl,
  }) async {
    print(
        "Parent: Sending order prepared notification with childImageUrl: $childImageUrl");

    final notification = NotificationModel(
      id: '', // Firestore will generate this
      userId: parentId,
      title: 'Order Prepared',
      body: 'The order for $childName has been prepared by $preparedBy',
      type: 'order_prepared',
      data: {
        'orderId': orderId,
        'preparedBy': preparedBy,
        'childImageUrl':
            childImageUrl, // Include child image URL in notification data
      },
      timestamp: DateTime.now(),
    );

    try {
      await _notificationService.saveNotification(notification);
      print("Parent: Order prepared notification sent successfully");
    } catch (e) {
      print("Parent: Failed to send order prepared notification: $e");
      errorMessage.value = 'Failed to send notification: $e';
    }
  }

  // Method to send notification when order is delivered
  Future<void> sendOrderDeliveredNotification({
    required String parentId,
    required String orderId,
    required String childName,
    required String deliveredBy,
    String? childImageUrl,
  }) async {
    print(
        "Parent: Sending order delivered notification with childImageUrl: $childImageUrl");

    final notification = NotificationModel(
      id: '', // Firestore will generate this
      userId: parentId,
      title: 'Order Delivered',
      body: 'The order for $childName has been delivered by $deliveredBy',
      type: 'order_delivered',
      data: {
        'orderId': orderId,
        'deliveredBy': deliveredBy,
        'childImageUrl':
            childImageUrl, // Include child image URL in notification data
      },
      timestamp: DateTime.now(),
    );

    try {
      await _notificationService.saveNotification(notification);
      print("Parent: Order delivered notification sent successfully");
    } catch (e) {
      print("Parent: Failed to send order delivered notification: $e");
      errorMessage.value = 'Failed to send notification: $e';
    }
  }
}
