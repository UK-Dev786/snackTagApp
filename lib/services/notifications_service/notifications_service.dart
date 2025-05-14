import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:snacktag/services/cloud_functions_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channels
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
    playSound: true,
  );

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    try {
      // Request permissions with provisional permission for iOS
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get initial token
      String? token = await _fcm.getToken();
      print("FCM token is: $token");

      if (token != null) {
        await updateFCMToken(token);
      } else {
        print("⚠️ Failed to get FCM token");
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        print("🔄 FCM token refreshed: $newToken");
        updateFCMToken(newToken);
      });

      // Set up message handlers
      await _setupMessageHandlers();

      print("✅ Notification service initialized successfully");
    } catch (e) {
      print("❌ Error initializing notification service: $e");
    }
  }

  Future<void> _setupMessageHandlers() async {
    // Handle messages when app is terminated/killed
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      await _handleMessage(initialMessage, isInitialMessage: true);
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle messages in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleForegroundMessage(message);
    });

    // Handle when user taps on notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleMessage(message, isBackgroundTap: true);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    await _handleBackgroundMessage(message);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Save notification to Firestore for persistence
    final notification = NotificationModel(
      id: '',
      userId: message.data['userId'] ?? '',
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? '',
      data: message.data,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(notification.userId)
        .collection('notifications')
        .add(notification.toJson());
  }

  Future<void> _handleMessage(
    RemoteMessage message, {
    bool isInitialMessage = false,
    bool isBackgroundTap = false,
  }) async {
    final notificationType = message.data['type'] as String?;

    switch (notificationType) {
      case 'order_prepared':
        Get.toNamed('/order-details', arguments: message.data['orderId']);
        break;
      case 'order_delivered':
        // Check if this is a cafe owner notification
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(message.data['userId'])
            .get();

        if (userDoc.exists &&
            userDoc.data() != null &&
            userDoc.data()!['role'] == 'cafeteriaAdmin') {
          // This is a cafe owner, navigate to the cafe owner order delivery details
          print(
              "🔄 Cafe owner notification - navigating to cafe owner order delivery details");
          Get.toNamed(
            '/cafe-owner-order-delivery-details',
            arguments: {
              'orderId': message.data['orderId'],
              'staffName': message.data['deliveredBy'] ?? 'Staff',
              'childName': message.data['childName'] ?? 'Student',
              'amount': message.data['amount'] ?? '0.00',
            },
          );
        } else {
          // This is a parent, navigate to the parent order delivery details
          print(
              "🔄 Parent notification - navigating to parent order delivery details");
          Get.toNamed(
            '/parent-order-delivery-details',
            arguments: {
              'orderId': message.data['orderId'],
              'staffName': message.data['deliveredBy'] ?? 'Staff',
              'childName': message.data['childName'] ?? 'Student',
            },
          );
        }
        break;
      case 'new_order':
        print(
            "🔄 Navigating to new order details with ID: ${message.data['orderId']}");

        // Navigate to our new order details view with all the necessary data
        Get.toNamed('/new-order-details', arguments: {
          'orderId': message.data['orderId'],
          'parentId': message.data['parentId'],
          'childName': message.data['childName'] ?? 'Student',
        });
        break;
      case 'low_balance':
        // Show a dialog instead of direct navigation
        Get.dialog(
          AlertDialog(
            title: Text('Low Balance Alert'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your wallet balance is insufficient for meal orders.',
                ),
                SizedBox(height: 10),
                Text(
                  'Please add funds to your wallet to continue placing orders.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  // Navigate to wallet with required amount
                  Get.toNamed('/wallet', arguments: {
                    'showTopUp': true,
                    'requiredAmount':
                        double.parse(message.data['requiredAmount'] ?? '0'),
                  });
                },
                child: Text('Add Funds'),
              ),
            ],
          ),
        );
        break;
      case 'new_message':
        Get.toNamed('/chat', arguments: message.data['chatId']);
        break;
      default:
        // Handle unknown notification types
        Get.toNamed('/notifications');
    }

    // Mark notification as read if user tapped it
    if (isBackgroundTap || isInitialMessage) {
      await markNotificationAsRead(message.data['notificationId']);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> updateFCMToken(String token) async {
    try {
      // Get current user ID
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('⚠️ Cannot update FCM token: No user is logged in');
        return;
      }

      print('🔄 Updating FCM token for user $userId: $token');

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Update the token in the user document
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token updated successfully for user: $userId');
      } else {
        print('⚠️ User document not found for ID: $userId');
        // Create the document if it doesn't exist
        await _firestore.collection('users').doc(userId).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          'userId': userId,
        }, SetOptions(merge: true));
        print('✅ Created user document with FCM token for user: $userId');
      }
    } catch (e) {
      print('❌ Error updating FCM token: $e');
    }
  }

  // Method to update FCM token specifically for staff users
  Future<void> updateFCMTokenForStaff(String staffId) async {
    try {
      if (staffId.isEmpty) {
        print('⚠️ Cannot update FCM token for staff: Staff ID is empty');
        return;
      }

      // Get the current FCM token
      String? token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ Cannot update FCM token for staff: Token is empty');
        return;
      }

      print('🔄 Updating FCM token for staff $staffId: $token');

      // Check if staff document exists in users collection
      final userDoc = await _firestore.collection('users').doc(staffId).get();

      if (userDoc.exists) {
        // Update the token in the user document
        await _firestore.collection('users').doc(staffId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token updated successfully for staff: $staffId');
      } else {
        print(
            '⚠️ Staff document not found in users collection for ID: $staffId');

        // Try to find the staff in staffData collection
        final staffDoc =
            await _firestore.collection('staffData').doc(staffId).get();

        if (staffDoc.exists) {
          // Create a document in users collection for this staff
          await _firestore.collection('users').doc(staffId).set({
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            'userId': staffId,
            'role': 'staff',
            'isStaff': true,
          }, SetOptions(merge: true));
          print('✅ Created user document with FCM token for staff: $staffId');
        } else {
          print('❌ Staff not found in staffData collection either: $staffId');
        }
      }
    } catch (e) {
      print('❌ Error updating FCM token for staff: $e');
    }
  }

  Future<void> saveNotification(NotificationModel notification) async {
    try {
      // Validate userId
      if (notification.userId.isEmpty) {
        print('Error: Cannot save notification - userId is empty');
        // Try to get current user ID as fallback
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          throw Exception('No user ID available to save notification');
        }
        notification = notification.copyWith(userId: currentUserId);
      }

      // Check for duplicate notification using notificationUid if available
      final String notificationUid = notification.data['notificationUid'] ?? '';
      if (notificationUid.isNotEmpty) {
        final exists = await _checkNotificationExists(
            notification.userId, notificationUid);
        if (exists) {
          print(
              '🚫 Duplicate notification detected with UID: $notificationUid - skipping save');
          return; // Skip saving this notification
        }
      }

      await _firestore
          .collection('users')
          .doc(notification.userId)
          .collection('notifications')
          .doc(notification.id.isEmpty
              ? null
              : notification.id) // Let Firestore generate ID if empty
          .set(notification.toJson());
    } catch (e) {
      print('Error saving notification: $e');
      rethrow;
    }
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    print("🔍 Getting notifications for user: $userId");

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      print(
          "📊 Firestore snapshot received: ${snapshot.docs.length} documents");

      // Parse all notifications
      final List<NotificationModel> allNotifications = snapshot.docs.map((doc) {
        try {
          final data = {
            ...doc.data(),
            'id': doc.id,
          };
          return NotificationModel.fromJson(data);
        } catch (e) {
          print("❌ Error parsing notification document ${doc.id}: $e");
          // Return a placeholder notification to avoid breaking the stream
          return NotificationModel(
            id: doc.id,
            userId: userId,
            title: "Error parsing notification",
            body: "There was an error loading this notification",
            type: "error",
            data: {},
            timestamp: DateTime.now(),
            isRead: false,
          );
        }
      }).toList();

      // Filter out duplicates based on notificationUid
      final Map<String, NotificationModel> uniqueNotifications = {};

      for (var notification in allNotifications) {
        final String notificationUid =
            notification.data['notificationUid'] ?? '';

        // If this notification has a UID and we haven't seen it before, or it doesn't have a UID
        if ((notificationUid.isNotEmpty &&
                !uniqueNotifications.containsKey(notificationUid)) ||
            notificationUid.isEmpty) {
          // For notifications without UID, use the document ID as the key
          final String key =
              notificationUid.isNotEmpty ? notificationUid : notification.id;
          uniqueNotifications[key] = notification;
        }
      }

      // Convert back to list and sort by timestamp (newest first)
      final List<NotificationModel> result = uniqueNotifications.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print("📊 Filtered to ${result.length} unique notifications");

      return result;
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      if (message.notification == null) return;

      // Show local notification
      await _localNotifications.show(
        DateTime.now().millisecond, // unique ID
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data), // Include data for tap handling
      );

      // We don't need to save the notification to Firestore here
      // It's already saved by the sendNotification method
    } catch (e) {
      print('❌ Error handling foreground message: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && notificationId.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }
  }

  Future<void> clearAllNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await _localNotifications.cancelAll();
    }
  }

//  void _handleLocalNotificationTap(String? payload) async {
//   if (payload != null) {
//     final data = jsonDecode(payload);
//     if (data['type'] == 'order_prepared') {
//       Get.toNamed('/order-details', arguments: data['orderId']);
//     }
//   }
// }
  Future<void> _handleLocalNotificationTap(
      NotificationResponse response) async {
    final String? payload = response.payload;

    if (payload != null) {
      final data = jsonDecode(payload);

      if (data['type'] == 'order_prepared') {
        // Check if this is a parent notification
        final userId = data['userId'] ?? FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists &&
              userDoc.data() != null &&
              userDoc.data()!['role'] != 'cafeteriaAdmin' &&
              userDoc.data()!['role'] != 'staff') {
            // This is a parent, navigate to the parent order preparation details
            print(
                "🔄 Parent preparation notification - navigating to parent order preparation details");
            Get.toNamed(
              '/parent-order-preparation-details',
              arguments: {
                'orderId': data['orderId'],
                'preparedBy': data['preparedBy'] ?? 'Staff',
                'childName': data['childName'] ?? 'Student',
                'childImageUrl': data['childImageUrl'],
              },
            );
          } else {
            // This is a staff or cafe owner, navigate to the regular order details
            Get.toNamed('/order-details', arguments: data['orderId']);
          }
        } else {
          // Fallback to regular order details
          Get.toNamed('/order-details', arguments: data['orderId']);
        }
      } else if (data['type'] == 'new_order') {
        print("🔄 Navigating to new order details with ID: ${data['orderId']}");

        // Navigate to our new order details view with all the necessary data
        Get.toNamed('/new-order-details', arguments: {
          'orderId': data['orderId'],
          'parentId': data['parentId'],
          'childName': data['childName'] ?? 'Student',
        });
      } else if (data['type'] == 'order_delivered') {
        // Check if this is a cafe owner notification
        final userId = data['userId'] ?? FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists &&
              userDoc.data() != null &&
              userDoc.data()!['role'] == 'cafeteriaAdmin') {
            // This is a cafe owner, navigate to the cafe owner order delivery details
            print(
                "🔄 Cafe owner notification - navigating to cafe owner order delivery details");
            Get.toNamed(
              '/cafe-owner-order-delivery-details',
              arguments: {
                'orderId': data['orderId'],
                'staffName': data['deliveredBy'] ?? 'Staff',
                'childName': data['childName'] ?? 'Student',
                'amount': data['amount'] ?? '0.00',
              },
            );
          } else {
            // This is a parent, navigate to the parent order delivery details
            print(
                "🔄 Parent notification - navigating to parent order delivery details");
            Get.toNamed(
              '/parent-order-delivery-details',
              arguments: {
                'orderId': data['orderId'],
                'staffName': data['deliveredBy'] ?? 'Staff',
                'childName': data['childName'] ?? 'Student',
              },
            );
          }
        }
      }
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('📤 Sending notification to user: $userId');
      print('📤 Notification title: $title');
      print('📤 Notification body: $body');
      print('📤 Notification data: $data');

      // Check if this is a new order notification and the recipient is the current user (parent)
      // If so, don't send the notification to avoid parents receiving their own order notifications
      if (type == 'new_order' &&
          FirebaseAuth.instance.currentUser?.uid == userId) {
        print('🚫 Skipping notification to parent for their own order');
        return;
      }

      // Check if this notification has a unique ID
      final String notificationUid = data['notificationUid'] ?? '';

      // If no UID provided, generate one
      final Map<String, dynamic> finalData = {...data};
      if (notificationUid.isEmpty) {
        finalData['notificationUid'] =
            DateTime.now().millisecondsSinceEpoch.toString();
        print(
            '📤 Generated new notificationUid: ${finalData['notificationUid']}');
      }

      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('⚠️ User document not found for ID: $userId');
        return;
      }

      final fcmToken = userDoc.data()?['fcmToken'];
      print('📱 FCM token found for user: $userId is $fcmToken');

      // Make sure we're not sending to the current user's token for new_order notifications
      if (type == 'new_order' &&
          FirebaseAuth.instance.currentUser != null &&
          fcmToken == await _fcm.getToken()) {
        print(
            '🚫 Skipping FCM notification to parent for their own order (token match)');
        return;
      }

      if (fcmToken == null || fcmToken.toString().isEmpty) {
        print('⚠️ No valid FCM token found for user: $userId');

        // Try to get a new token if this is the current user
        if (FirebaseAuth.instance.currentUser?.uid == userId) {
          print('🔄 Attempting to refresh FCM token for current user');
          String? newToken = await _fcm.getToken();
          if (newToken != null) {
            print('✅ Got new FCM token: $newToken');
            await updateFCMToken(newToken);

            // Use the new token
            await Get.find<CloudFunctionsService>().sendFCM(
              tokens: [newToken],
              title: title,
              message: body,
            );

            // Don't save notification here - it will be saved when received
            print(
                '📤 FCM sent with new token, notification will be saved when received');
            return;
          }
        }
        return;
      }

      // Check if notification with this UID already exists
      if (notificationUid.isNotEmpty) {
        final exists = await _checkNotificationExists(userId, notificationUid);
        if (exists) {
          print(
              '🚫 Notification with UID $notificationUid already exists, skipping save');
          // Still send FCM but don't save again
          await Get.find<CloudFunctionsService>().sendFCM(
            tokens: [fcmToken],
            title: title,
            message: body,
          );
          return;
        }
      }

      // Save notification to Firestore for history
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: finalData,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Save the notification to Firestore
      await saveNotification(notification);

      // Send FCM notification
      await Get.find<CloudFunctionsService>().sendFCM(
        tokens: [fcmToken],
        title: title,
        message: body,
      );

      print('✅ FCM notification sent successfully to user: $userId');
    } catch (e) {
      print('❌ Error sending notification: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  // Add this helper method to check if a notification already exists
  Future<bool> _checkNotificationExists(
      String userId, String notificationUid) async {
    if (userId.isEmpty || notificationUid.isEmpty) return false;

    print(
        "🔍 Checking for existing notification - userId: $userId, notificationUid: $notificationUid");

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('data.notificationUid', isEqualTo: notificationUid)
        .limit(1)
        .get();

    final exists = snapshot.docs.isNotEmpty;
    print(
        "🔍 Notification exists: $exists (found ${snapshot.docs.length} docs)");

    return exists;
  }

  // Add a method to force refresh notifications from Firestore
  Future<void> refreshNotifications(String userId) async {
    try {
      print("🔄 Forcing refresh of notifications for user: $userId");

      if (userId.isEmpty) {
        print("🚫 Cannot refresh notifications: userId is empty");
        return;
      }

      // Get a fresh snapshot from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      print(
          "📊 Refreshed notifications: ${snapshot.docs.length} documents found");

      // No need to process the data here, the stream will handle that
      // This just ensures we've made a fresh request to Firestore
    } catch (e) {
      print("❌ Error refreshing notifications: $e");
      rethrow;
    }
  }
}
