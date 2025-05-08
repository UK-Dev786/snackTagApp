import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/app/modules/staff_history_list/controllers/staff_history_list_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

import '../controllers/staff_order_history_controller.dart';

class StaffOrderHistoryView extends GetView<StaffOrderHistoryController> {
  const StaffOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order History',
          style: AppTextStyles.MetropolisMedium.copyWith(
            fontSize: 18,
            color: const Color(0xFF434343),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => controller.previousMonth(),
                ),
                Text(
                  controller.currentMonthYear.value,
                  style: AppTextStyles.MetropolisMedium.copyWith(
                    fontSize: 16,
                    color: AppColors.gradientEndColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => controller.nextMonth(),
                ),
              ],
            )),
          ),
          
          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          
          // History content
          Expanded(
            child: GetBuilder<StaffHistoryListController>(
              init: StaffHistoryListController(),
              id: 'staffOrderDeliveredId',
              builder: (historyController) {
                return Obx(() {
                  if (historyController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gradientEndColor,
                      ),
                    );
                  }

                  if (historyController.deliveredOrdersList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/empty_history.png',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders for this month',
                            style: AppTextStyles.MetropolisRegular.copyWith(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group orders by date
                  Map<String, List<dynamic>> ordersByDate = {};
                  for (var order in historyController.deliveredOrdersList) {
                    if (order.orderDeliveredTime != null && order.orderDeliveredTime!.isNotEmpty) {
                      try {
                        DateTime deliveryTime = DateTime.parse(order.orderDeliveredTime!);
                        String dateKey = DateFormat('d MMMM yyyy').format(deliveryTime);
                        
                        if (!ordersByDate.containsKey(dateKey)) {
                          ordersByDate[dateKey] = [];
                        }
                        ordersByDate[dateKey]!.add(order);
                      } catch (e) {
                        print("Error parsing delivery time: $e");
                      }
                    }
                  }

                  // Convert map to list for ListView
                  List<MapEntry<String, List<dynamic>>> dateEntries = ordersByDate.entries.toList();
                  
                  // Sort dates in descending order (newest first)
                  dateEntries.sort((a, b) {
                    DateTime dateA = DateFormat('d MMMM yyyy').parse(a.key);
                    DateTime dateB = DateFormat('d MMMM yyyy').parse(b.key);
                    return dateB.compareTo(dateA);
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: dateEntries.length,
                    itemBuilder: (context, dateIndex) {
                      String date = dateEntries[dateIndex].key;
                      List<dynamic> ordersForDate = dateEntries[dateIndex].value;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 16, left: 8),
                            child: Text(
                              date,
                              style: AppTextStyles.MetropolisBold.copyWith(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          
                          // Orders for this date
                          ...ordersForDate.map((order) => _buildOrderCard(context, order)),
                        ],
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    // Extract delivery time
    String timeStr = "10:00am";
    if (order.orderDeliveredTime != null && order.orderDeliveredTime!.isNotEmpty) {
      try {
        DateTime deliveryTime = DateTime.parse(order.orderDeliveredTime!);
        timeStr = DateFormat('h:mma').format(deliveryTime).toLowerCase();
      } catch (e) {
        print("Error parsing delivery time for time display: $e");
      }
    }

    // Calculate total price
    double price = 0;
    if (order.mealPrice != null) {
      try {
        price = double.parse(order.mealPrice.toString());
      } catch (e) {
        print("Error parsing meal price: $e");
      }
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.STAFF_DELIVERED_ORDER_HISTORY_DETAILS,
          arguments: {
            "DeliveredOrderData": order,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: order.childImage != null && order.childImage!.isNotEmpty
                    ? Image.network(
                        order.childImage!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
              ),
              
              const SizedBox(width: 12),
              
              // Order details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.childName ?? "Unknown",
                      style: AppTextStyles.MetropolisMedium.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Child School ID",
                      style: AppTextStyles.MetropolisRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      order.mealName ?? "Unknown Meal",
                      style: AppTextStyles.MetropolisRegular.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    if (order.drinkName != null && order.drinkName!.isNotEmpty)
                      Text(
                        order.drinkName!,
                        style: AppTextStyles.MetropolisRegular.copyWith(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Time and price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: AppTextStyles.MetropolisRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${price.toStringAsFixed(0)}",
                    style: AppTextStyles.MetropolisBold.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
