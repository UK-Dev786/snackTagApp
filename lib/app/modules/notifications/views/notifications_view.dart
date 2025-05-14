import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/notification_model.dart';

import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Image.asset(
              AppImages.authImg,
              height: 70,
              width: 57,
            ),
            const SizedBox(height: 30),
            Text(
              'NOTIFICATIONS', // Title text (fixed typo)
              style: AppTextStyles.MetropolisBold.copyWith(
                fontSize: 18,
                color: const Color(0xFF434343),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              color: Color(0xFFEEEEEE),
              thickness: 1,
              height: 1,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(controller.errorMessage.value),
                  );
                }

                if (controller.notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications'),
                  );
                }

                // Get unique notifications to avoid duplicates
                final uniqueNotifications =
                    _getUniqueNotifications(controller.notifications);

                // Group notifications by date category
                final groupedNotifications =
                    _groupNotificationsByDate(uniqueNotifications);

                // Convert the map to a list of entries for ListView
                final dateGroups = groupedNotifications.entries.toList();

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: dateGroups.length,
                  itemBuilder: (context, groupIndex) {
                    final dateCategory = dateGroups[groupIndex].key;
                    final notificationsInGroup = dateGroups[groupIndex].value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40.0, top: 16.0, bottom: 8.0),
                          child: Text(
                            dateCategory,
                            style: AppTextStyles.MetropolisLight.copyWith(
                              fontSize: 18,
                              color: const Color(0xFFBFBFBF),
                            ),
                          ),
                        ),

                        // Notifications for this date category
                        ...notificationsInGroup
                            .map((notification) => Dismissible(
                                  key: Key(notification.id),
                                  onDismissed: (_) {
                                    controller
                                        .deleteNotification(notification.id);
                                  },
                                  child: NotificationItem(
                                    notification: notification,
                                  ),
                                ))
                            .toList(),

                        // Add some space between groups
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to filter out duplicate notifications
  List<NotificationModel> _getUniqueNotifications(
      List<NotificationModel> notifications) {
    final Map<String, NotificationModel> uniqueMap = {};

    for (var notification in notifications) {
      // Create a unique key based on title and body
      final String key = "${notification.title}|${notification.body}";

      // Only keep the first notification with this title and body
      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = notification;
      }
    }

    // Convert back to list and sort by timestamp (newest first)
    return uniqueMap.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _getTimeHeader() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    if (controller.notifications.isEmpty) {
      return 'No notifications';
    }

    final latestNotification = controller.notifications.first;
    final notificationDate = DateTime(latestNotification.timestamp.year,
        latestNotification.timestamp.month, latestNotification.timestamp.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (notificationDate == twoDaysAgo) {
      return '2 days ago';
    } else if (notificationDate == threeDaysAgo) {
      return '3 days ago';
    } else {
      return DateFormat('MMM d').format(notificationDate);
    }
  }

  // Helper method to group notifications by date category
  Map<String, List<NotificationModel>> _groupNotificationsByDate(
      List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    for (var notification in notifications) {
      final notificationDate = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );

      String dateCategory;

      if (notificationDate == today) {
        dateCategory = 'Today';
      } else if (notificationDate == yesterday) {
        dateCategory = 'Yesterday';
      } else if (notificationDate == twoDaysAgo) {
        dateCategory = '2 days ago';
      } else if (notificationDate == threeDaysAgo) {
        dateCategory = '3 days ago';
      } else {
        dateCategory = DateFormat('MMM d').format(notificationDate);
      }

      if (!grouped.containsKey(dateCategory)) {
        grouped[dateCategory] = [];
      }

      grouped[dateCategory]!.add(notification);
    }

    return grouped;
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({
    required this.notification,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Call the controller's handleNotificationTap method
            Get.find<NotificationsController>()
                .handleNotificationTap(notification);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              // Remove fixed height to allow content to determine size
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: notification.data.containsKey('childImageUrl') &&
                            notification.data['childImageUrl'] != null &&
                            notification.data['childImageUrl']
                                .toString()
                                .isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              notification.data['childImageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                    "Parent: Error loading child image: $error");
                                return const Icon(Icons.notifications);
                              },
                            ),
                          )
                        : const Icon(Icons.notifications),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min, // Use minimum space needed
                      children: [
                        Text(
                          notification.title,
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            color: const Color(0xFF334856),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.body,
                          style: AppTextStyles.MetropolisRegular.copyWith(
                            color: const Color(0xFF6E8CA0),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatTimestamp(notification.timestamp),
                            style: AppTextStyles.MetropolisRegular.copyWith(
                              color: const Color(0xFF798186),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: Color(0xFFEEEEEE),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
