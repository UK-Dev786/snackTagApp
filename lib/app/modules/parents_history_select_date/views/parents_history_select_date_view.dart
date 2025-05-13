import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/appBuilderId.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/models/cefeteria_admin/upcoming_meal_order.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/parents_history_select_date_controller.dart';

class ParentsHistorySelectDateView
    extends GetView<ParentsHistorySelectDateController> {
  const ParentsHistorySelectDateView({super.key});
  @override
  Widget build(BuildContext context) {
    // final historyController = Get.find<ParentsHistoryController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<ParentsHistorySelectDateController>(
          init: ParentsHistorySelectDateController(),
          id: parentsHistorySelectDataId,
          builder: (parentsHSDCont) {
            if (parentsHSDCont.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (parentsHSDCont.upComingMealOrderList.isEmpty) {
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay:
                        parentsHSDCont.selectedDate.value, // Use selected date
                    selectedDayPredicate: (day) {
                      return parentsHSDCont.isDateSelected.value &&
                          parentsHSDCont.isSameDay(
                              day, parentsHSDCont.selectedDate.value);
                    },
                    onDaySelected: parentsHSDCont.onDaySelected,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        String hasMealToday =
                            parentsHSDCont.checkIfDateHasMeal(day); // Pass day
                        bool isSelected = parentsHSDCont.isDateSelected.value &&
                            parentsHSDCont.isSameDay(
                                day, parentsHSDCont.selectedDate.value);

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 6.0),
                                decoration: isSelected
                                    ? BoxDecoration(
                                        color: AppColors.gradientEndColor,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      )
                                    : null,
                                child: Text(
                                  '${day.day}',
                                  style: AppTextStyles.RobotoRegular.copyWith(
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF2E2E2E),
                                  ),
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
                        bool isSelected = parentsHSDCont.isDateSelected.value &&
                            parentsHSDCont.isSameDay(
                                day, parentsHSDCont.selectedDate.value);

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
                                borderRadius: BorderRadius.circular(
                                    8.0), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      )
                                    : null,
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
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${parentsHSDCont.parentAddWalletModel.value!.amount}\$',
                          style: AppTextStyles.RobotoRegular.copyWith(
                            color: const Color(0xFFBFBFBF),
                            fontSize: 13,
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 8,
                    ),
                    child: Text(
                      parentsHSDCont.isDateSelected.value
                          ? 'Orders for ${DateFormat('MMMM d, yyyy').format(parentsHSDCont.selectedDate.value)}'
                          : 'Upcoming',
                      style: AppTextStyles.RobotoRegular.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFBFBFBF),
                      ),
                    ),
                  ),

                  // Upcoming Orders Section - No longer in an Expanded widget
                  if (parentsHSDCont.isDateSelected.value &&
                      parentsHSDCont.filteredUpComingMealOrderList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
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
                              'No orders for ${DateFormat('MMMM d, yyyy').format(parentsHSDCont.selectedDate.value)}',
                              style: AppTextStyles.PoppinsMedium.copyWith(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                parentsHSDCont.isDateSelected.value = false;
                                parentsHSDCont.filteredUpComingMealOrderList
                                    .clear();
                                parentsHSDCont
                                    .update(['parentsHistorySelectDataId']);
                              },
                              child: Text(
                                'Show all upcoming orders',
                                style: AppTextStyles.PoppinsMedium.copyWith(
                                  fontSize: 14,
                                  color: AppColors.gradientEndColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: parentsHSDCont.isDateSelected.value &&
                              parentsHSDCont
                                  .filteredUpComingMealOrderList.isNotEmpty
                          ? parentsHSDCont.filteredUpComingMealOrderList.length
                          : parentsHSDCont.upComingMealOrderList.length,
                      padding: const EdgeInsets.only(top: 0),
                      itemBuilder: (context, index) {
                        return _buildOrderCard(
                          context,
                          parentsHSDCont.isDateSelected.value &&
                                  parentsHSDCont
                                      .filteredUpComingMealOrderList.isNotEmpty
                              ? parentsHSDCont
                                  .filteredUpComingMealOrderList[index]
                              : parentsHSDCont.upComingMealOrderList[index],
                        );
                      },
                    ),
                ],
              ),
            );
          }),
    );
  }
}

Widget _buildOrderCard(
  BuildContext context,
  // ParentsHistorySelectDateController parentsHSDCont,
  UpcomingMealOrder upcomingOrderCount,
  // ParentsHistoryController historyController
) {
  return GestureDetector(
    onTap: () {
      print(
          "List of student IDs being passed to detail view: ${upcomingOrderCount.studentIds}");
      print("Student IDs type: ${upcomingOrderCount.studentIds.runtimeType}");
      // Make sure we're passing a non-null list
      final studentIds = upcomingOrderCount.studentIds ?? [];
      print("Is studentIds empty? ${studentIds.isEmpty}");
      print("Meal name being passed: ${upcomingOrderCount.itemName}");

      Get.toNamed(Routes.PARENT_UPCOMING_ORDER_DETAIL, arguments: {
        "orderStudentIds": studentIds,
        "mealName": upcomingOrderCount.itemName,
      });
      // historyController.updateSelectedIndex(1);
    },
    child: Container(
      height: 72, // Fixed height for each item
      width: double.infinity, // Infinite width
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: AppColors.gradientEndColor, // Dot color
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
                    ), // H// Hardcoded subtitle
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Centered Text ($25)
                  Text(
                    "\$${upcomingOrderCount.itemPrice ?? "N/A"}",
                    style: AppTextStyles.PoppinsMedium.copyWith(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right Arrow Icon inside a black container
                  Container(
                    height: 30,
                    width: 30,
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.black, // Black background
                      shape:
                          BoxShape.rectangle, // Circle shape for the container
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Image.asset(
                      'assets/icon/arrow_right.png', // Right arrow icon

                      fit: BoxFit
                          .contain, // Ensures the icon fits within the container
                      color: Colors.white, // White color for the icon
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}
