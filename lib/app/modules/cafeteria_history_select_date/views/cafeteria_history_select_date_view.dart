import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_history/controllers/cafeteria_history_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
// // import 'package:snacktag/app/routes/app_routes.dart';t';
import 'package:snacktag/config/appBuilderId.dart';

import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/cefeteria_admin/upcoming_meal_order.dart';

import '../controllers/cafeteria_history_select_date_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class CafeteriaHistorySelectDateView extends StatelessWidget {
  const CafeteriaHistorySelectDateView({super.key});
  @override
  Widget build(BuildContext context) {
    // final historyController = Get.find<CafeteriaHistoryController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<CafeteriaHistorySelectDateController>(
          init: CafeteriaHistorySelectDateController(),
          id: cafateriaHistorySelectDataId,
          builder: (cafateriaHSDCont) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(), // Current visible month
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      String hasMealToday =
                          cafateriaHSDCont.checkIfDateHasMeal(day); // Pass day

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppTextStyles.RobotoRegular.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF2E2E2E),
                              ),
                            ),
                            if (hasMealToday.isNotEmpty)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.gradientEndColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.gradientEndColor,
                                  AppColors.gradientStartColor
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${day.day}', // Display the day number
                                  style: AppTextStyles.RobotoBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                    [
                                      'SUN',
                                      'MON',
                                      'TUE',
                                      'WED',
                                      'THU',
                                      'FRI',
                                      'SAT'
                                    ][day.weekday % 7], // Display weekday
                                    style: AppTextStyles.RobotoLight.copyWith(
                                      fontSize: 12,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    todayTextStyle: const TextStyle(
                        color: Colors.transparent), // Hide default styling
                    outsideDaysVisible: false,
                    defaultTextStyle: AppTextStyles.RobotoRegular.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF2E2E2E),
                    ),
                    weekendTextStyle: AppTextStyles.RobotoRegular.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    headerPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    formatButtonVisible: false,
                    titleCentered: false,
                    titleTextStyle: AppTextStyles.RobotoRegular.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF2E2E2E),
                    ),
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: AppTextStyles.RobotoRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFFBFBFBF),
                    ),
                    weekendStyle: AppTextStyles.RobotoRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFFBFBFBF),
                    ),
                    dowTextFormatter: (date, locale) {
                      return [
                        "S",
                        "M",
                        "T",
                        "W",
                        "T",
                        "F",
                        "S"
                      ][date.weekday % 7];
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: Color(0xFFEEEEEE),
                    thickness: 1,
                    height: 1,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 8,
                  ),
                  child: Text(
                    'Upcoming',
                    style: AppTextStyles.RobotoRegular.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBFBFBF),
                    ),
                  ),
                ),

                // Upcoming Orders Section
                Expanded(
                  child: Obx(() {
                    if (cafateriaHSDCont.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (cafateriaHSDCont.upComingMealOrderList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Upcoming Orders',
                              style: AppTextStyles.PoppinsMedium.copyWith(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: cafateriaHSDCont.upComingMealOrderList.length,
                      padding: const EdgeInsets.only(top: 0),
                      itemBuilder: (context, index) {
                        return _buildOrderCard(context, cafateriaHSDCont,
                            cafateriaHSDCont.upComingMealOrderList[index]);
                      },
                    );
                  }),
                ),
              ],
            );
          }),
    );
  }
}

Widget _buildOrderCard(
    BuildContext context,
    CafeteriaHistorySelectDateController cafateriaHSDCont,
    UpcomingMealOrder upcomingOrderCount) {
  return GestureDetector(
    onTap: () {
      print("List of st kjkkkkkhudent IDs: ${upcomingOrderCount.studentIds}");
      Get.toNamed(Routes.CAFETERIA_UPCOMING_DETAIL, arguments: {
        "orderStudentIds": upcomingOrderCount.studentIds,
      });
      // historyController.updateSelectedIndex(1);
    },
    child: Container(
      height: 72, // Fixed height for each item
      width: double.infinity, // Infinite width
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // First column: Takes 10% of container width
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: Center(
              child: Container(
                width: 8.0, // Size of the dot
                height: 8.0, // Size of the dot
                decoration: const BoxDecoration(
                  color: AppColors.gradientStartColor, // Dot color
                  shape: BoxShape.circle, // Makes the container circular
                ),
              ),
            ),
          ),

          // Second column: Takes 75% of container width
          Container(
            width: MediaQuery.of(context).size.width * 0.60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6.0,
                  spreadRadius: 2.0,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left side image (50x50) and Name + Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Container(
                      width: 43, // Adjust width for more rectangular shape
                      height: 43, // Adjust height for more rectangular shape
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            8.0), // Optional: for rounded corners
                      ),
                      child: upcomingOrderCount.image != null &&
                              upcomingOrderCount.image!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                upcomingOrderCount.image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 127,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.error_outline_outlined,
                                    size: 20,
                                  ); //_buildPlaceholder();
                                },
                              ),
                            )
                          : const Icon(Icons.no_meals_sharp,
                              size: 20) //_buildPlaceholder();

                      ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      upcomingOrderCount.itemName ?? "", // Hardcoded title
                      style: AppTextStyles.PoppinsMedium.copyWith(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: DateFormat('MMMM ').format(DateTime.now()),
                            style: AppTextStyles.RobotoRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFFBFBFBF),
                            ),
                          ),
                          TextSpan(
                            text: '${DateTime.now().year}',
                            style: AppTextStyles.RobotoRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFFBFBFBF),
                            ),
                          ),
                        ],
                      ),
                    ), // Hardcoded subtitle
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Third column: Takes 15% of container width
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Column(
                children: [
                  Text(
                    upcomingOrderCount.expectedStudent.toString(),
                    style: AppTextStyles.PoppinsMedium.copyWith(
                      fontSize: 27,
                    ),
                  ),
                  Text("Expected",
                      style: AppTextStyles.PoppinsMedium.copyWith(
                        fontSize: 11,
                      )),
                  Text("No of Students",
                      style: AppTextStyles.PoppinsMedium.copyWith(
                        fontSize: 11,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
