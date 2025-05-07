import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
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
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NOTIFICATIONS', // Title text (fixed typo)
                  style: AppTextStyles.MetropolisMedium.copyWith(
                    fontSize: 18,
                    color: const Color(0xFF434343),
                  ),
                ),
                // const SizedBox(width: 10),
                // // Refresh button
                // IconButton(
                //   icon: const Icon(Icons.refresh, color: Color(0xFF434343)),
                //   onPressed: () {
                //     controller.refreshNotifications();
                //   },
                // ),
              ],
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

                return ListView.builder(
                  itemCount: uniqueNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = uniqueNotifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      onDismissed: (_) {
                        controller.deleteNotification(notification.id);
                      },
                      child: NotificationItem(
                        notification: notification,
                        onTap: () {
                          // Use the controller's method to handle notification tap
                          controller.handleNotificationTap(notification);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
    //   return Scaffold(
    //       backgroundColor: Colors.white,
    //       body: Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 4),
    //           child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 const SizedBox(
    //                   height: 70,
    //                 ),
    //
    //                 // Settings Title
    //                 Text(
    //                   'NOFITICATIONS', // Title text
    //                   style: AppTextStyles.MetropolisMedium.copyWith(
    //                     fontSize: 18,
    //                     color: const Color(0xFF434343),
    //                   ),
    //                 ),
    //
    //                 Expanded(
    //                   child: ListView.builder(
    //                     itemCount: controller.notifications.length,
    //                     itemBuilder: (context, index) {
    //                       final chat = controller.notifications[index];
    //                       return Column(
    //                         children: [
    //                           Padding(
    //                             padding:
    //                             const EdgeInsets.symmetric(horizontal: 16),
    //                             child: Container(
    //                               height: 80,
    //                               decoration: BoxDecoration(
    //                                 color: Colors.white,
    //                                 borderRadius: BorderRadius.circular(8),
    //                               ),
    //                               child: Row(
    //                                 children: [
    //                                   // Avatar
    //                                   // ClipRRect(
    //                                   //   borderRadius: BorderRadius.circular(35),
    //                                   //   child: Image.asset(
    //                                   //     chat.imageUrl,
    //                                   //     width: 70,
    //                                   //     height: 70,
    //                                   //     fit: BoxFit.cover,
    //                                   //   ),
    //                                   // ),
    //                                   const SizedBox(width: 12),
    //                                   // Chat Details
    //                                   Expanded(
    //                                     child: Column(
    //                                       crossAxisAlignment:
    //                                       CrossAxisAlignment.start,
    //                                       children: [
    //                                         // Title and Date Row
    //                                         const SizedBox(
    //                                           height: 10,
    //                                         ),
    //                                         Row(
    //                                           mainAxisAlignment:
    //                                           MainAxisAlignment.spaceBetween,
    //                                           children: [
    //                                             Text(
    //                                               chat.title,
    //                                               style: AppTextStyles.EuropaBold
    //                                                   .copyWith(
    //                                                 color: const Color(0xFF334856),
    //                                                 fontSize: 15,
    //                                               ),
    //                                             ),
    //                                             Text(
    //                                               _formatTimestamp(chat.timestamp),
    //                                               style: AppTextStyles.EuropaLight
    //                                                   .copyWith(
    //                                                 color: const Color(0xFF798186),
    //                                                 fontSize: 12,
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //
    //                                         Text(
    //                                           chat.body,
    //                                           style: AppTextStyles.EuropaLight
    //                                               .copyWith(
    //                                               color: const Color(0xFF6E8CA0),
    //                                               fontSize: 14),
    //                                           maxLines: 2,
    //                                           overflow: TextOverflow.ellipsis,
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                           const Padding(
    //                             padding: EdgeInsets.symmetric(horizontal: 16),
    //                             child: Divider(
    //                               color: Color(0xFFEEEEEE),
    //                               thickness: 1,
    //                             ),
    //                           )
    //                         ],
    //                       );
    //                     },
    //                   ),
    //                 )
    //               ])));
    // }
    // String _formatTimestamp(DateTime timestamp) {
    //   final now = DateTime.now();
    //   final difference = now.difference(timestamp);
    //
    //   if (difference.inDays > 7) {
    //     return DateFormat('MMM d').format(timestamp);
    //   } else if (difference.inDays > 0) {
    //     return '${difference.inDays}d ago';
    //   } else if (difference.inHours > 0) {
    //     return '${difference.inHours}h ago';
    //   } else if (difference.inMinutes > 0) {
    //     return '${difference.inMinutes}m ago';
    //   } else {
    //     return 'Just now';
    //   }
    // }
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

// class ChatItem {
//   final String name;
//   final String message;
//   final String timestamp;
//   final String imageUrl;
//
//   ChatItem({
//     required this.name,
//     required this.message,
//     required this.timestamp,
//     required this.imageUrl,
//   });
//
// }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    required this.notification,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                // color: notification.isRead
                //     ? Colors.white
                //     : Colors.blue.withOpacity(0.1),
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // if (notification.imageUrl != null)
                  //   ClipRRect(
                  //     borderRadius: BorderRadius.circular(35),
                  //     child: Image.network(
                  //       notification.imageUrl!,
                  //       width: 70,
                  //       height: 70,
                  //       fit: BoxFit.cover,
                  //       errorBuilder: (context, error, stackTrace) {
                  //         return Container(
                  //           width: 70,
                  //           height: 70,
                  //           color: Colors.grey[300],
                  //           child: Icon(Icons.notifications),
                  //         );
                  //       },
                  //     ),
                  //   )
                  // else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Icon(Icons.notifications),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.title,
                              style: AppTextStyles.EuropaBold.copyWith(
                                color: const Color(0xFF334856),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: AppTextStyles.EuropaLight.copyWith(
                                color: const Color(0xFF798186),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          notification.body,
                          style: AppTextStyles.EuropaLight.copyWith(
                            color: const Color(0xFF6E8CA0),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
