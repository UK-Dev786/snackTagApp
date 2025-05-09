import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/config/app_images.dart';

import '../../../../config/app_text_style.dart';
import '../../../../models/notification_model.dart';
import '../controllers/parents_orders_history_controller.dart';

class ParentsOrdersHistoryView extends GetView<ParentsOrdersHistoryController> {
  const ParentsOrdersHistoryView({super.key});
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
              'ORDER HISTORY', // Changed title to ORDER HISTORY
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

                // All notifications are already filtered in the controller
                final deliveredOrders = controller.notifications;

                if (deliveredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Order History',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Get unique notifications to avoid duplicates
                final uniqueDeliveredOrders =
                    _getUniqueNotifications(deliveredOrders);

                // Group notifications by date category
                final groupedOrders =
                    _groupNotificationsByDate(uniqueDeliveredOrders);

                // Convert the map to a list of entries for ListView
                final dateGroups = groupedOrders.entries.toList();

                return RefreshIndicator(
                  onRefresh: () => controller.refreshOrderHistory(),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: dateGroups.length,
                    itemBuilder: (context, groupIndex) {
                      final dateCategory = dateGroups[groupIndex].key;
                      final ordersInGroup = dateGroups[groupIndex].value;

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

                          // Orders for this date category
                          ...ordersInGroup
                              .map((order) => Dismissible(
                                    key: Key(order.id),
                                    onDismissed: (_) {
                                      controller.deleteNotification(order.id);
                                    },
                                    child: NotificationItem(
                                      notification: order,
                                    ),
                                  ))
                              .toList(),

                          // Add some space between groups
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

List<NotificationModel> _getUniqueNotifications(
    List<NotificationModel> notifications) {
  final Map<String, NotificationModel> uniqueMap = {};

  for (var notification in notifications) {
    // Create a unique key based on title, body, and timestamp (date only)
    final dateStr = DateFormat('yyyy-MM-dd').format(notification.timestamp);
    final String key = "${notification.title}|${notification.body}|$dateStr";

    // Only keep the first notification with this title and body for each day
    if (!uniqueMap.containsKey(key)) {
      uniqueMap[key] = notification;
    }
  }

  // Convert back to list and sort by timestamp (newest first)
  return uniqueMap.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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

  print(
      "ParentsOrdersHistory: Grouping ${notifications.length} notifications by date");
  print(
      "ParentsOrdersHistory: Today is ${DateFormat('yyyy-MM-dd').format(today)}");

  for (var notification in notifications) {
    final notificationDate = DateTime(
      notification.timestamp.year,
      notification.timestamp.month,
      notification.timestamp.day,
    );

    print(
        "ParentsOrdersHistory: Notification date: ${DateFormat('yyyy-MM-dd').format(notificationDate)}");

    String dateCategory;

    // Compare year, month, and day individually to avoid time comparison issues
    if (notificationDate.year == today.year &&
        notificationDate.month == today.month &&
        notificationDate.day == today.day) {
      dateCategory = 'Today';
      print("ParentsOrdersHistory: Categorized as Today");
    } else if (notificationDate.year == yesterday.year &&
        notificationDate.month == yesterday.month &&
        notificationDate.day == yesterday.day) {
      dateCategory = 'Yesterday';
      print("ParentsOrdersHistory: Categorized as Yesterday");
    } else if (notificationDate.year == twoDaysAgo.year &&
        notificationDate.month == twoDaysAgo.month &&
        notificationDate.day == twoDaysAgo.day) {
      dateCategory = '2 days ago';
    } else if (notificationDate.year == threeDaysAgo.year &&
        notificationDate.month == threeDaysAgo.month &&
        notificationDate.day == threeDaysAgo.day) {
      dateCategory = '3 days ago';
    } else {
      dateCategory = DateFormat('MMM d').format(notificationDate);
    }

    if (!grouped.containsKey(dateCategory)) {
      grouped[dateCategory] = [];
    }

    grouped[dateCategory]!.add(notification);
  }

  print(
      "ParentsOrdersHistory: Grouped into ${grouped.keys.length} date categories: ${grouped.keys.join(', ')}");

  // Ensure 'Today' category appears at the top if it exists
  if (grouped.containsKey('Today')) {
    final Map<String, List<NotificationModel>> reordered = {};
    reordered['Today'] = grouped['Today']!;
    grouped.forEach((key, value) {
      if (key != 'Today') {
        reordered[key] = value;
      }
    });
    return reordered;
  }

  return grouped;
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
                    color: Color.fromRGBO(128, 128, 128, 0.2),
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
                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Image.asset(
                                    AppImages.profile,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset(
                              AppImages.profile,
                              fit: BoxFit.contain,
                            ),
                          ),
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
                          _getSchoolName(notification),
                          style: AppTextStyles.MetropolisRegular.copyWith(
                            color: const Color(0xFF6E8CA0),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  // Helper method to extract school name from notification data
  String _getSchoolName(NotificationModel notification) {
    // Try to get school name directly from notification data
    if (notification.data.containsKey('schoolName') &&
        notification.data['schoolName'] != null &&
        notification.data['schoolName'].toString().isNotEmpty) {
      return notification.data['schoolName'].toString();
    }

    // Try to get school name from child data
    if (notification.data.containsKey('childSchool') &&
        notification.data['childSchool'] != null &&
        notification.data['childSchool'].toString().isNotEmpty) {
      return notification.data['childSchool'].toString();
    }

    // Try to get school name from cafeteria data
    if (notification.data.containsKey('cafeteriaSchool') &&
        notification.data['cafeteriaSchool'] != null &&
        notification.data['cafeteriaSchool'].toString().isNotEmpty) {
      return notification.data['cafeteriaSchool'].toString();
    }

    // Try to get cafeteria name as a fallback
    if (notification.data.containsKey('cafeteriaName') &&
        notification.data['cafeteriaName'] != null &&
        notification.data['cafeteriaName'].toString().isNotEmpty) {
      return notification.data['cafeteriaName'].toString();
    }

    // Try to get child name and use that as a fallback
    if (notification.data.containsKey('childName') &&
        notification.data['childName'] != null &&
        notification.data['childName'].toString().isNotEmpty) {
      return "${notification.data['childName'].toString()}'s school";
    }

    // Default fallback
    return 'School not specified';
  }
}
