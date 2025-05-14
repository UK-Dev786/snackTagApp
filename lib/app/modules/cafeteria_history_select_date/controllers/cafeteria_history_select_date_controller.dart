import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/appBuilderId.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/upcoming_meal_order.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafateria_history_selectdate_service.dart';
import 'package:intl/intl.dart';

class CafeteriaHistorySelectDateController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CafaterisHistorySelectDateService cafaterisHistorySelectDateService =
      CafaterisHistorySelectDateService();

  //TODO: Implement CafeteriaHistorySelectDateController

  final count = 0.obs;
  var isLoading = false.obs;
  String? cafateriaAdminName;
  var childrenList = <ParentsAddChildren>[].obs;
  var meals = <MealModel>[].obs;
  var upComingMealOrderList = <UpcomingMealOrder>[].obs;
  var filteredUpComingMealOrderList = <UpcomingMealOrder>[].obs;
  var isDateSelected = false.obs;

  // Selected date for filtering upcoming orders
  Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() async {
    await fetchCafateriaName();
    fetchCafateriaChildren();
    _fetchCafeteriaMeals();

    super.onInit();
  }

  Future<void> fetchCafateriaName() async {
    final user = _auth.currentUser;
    // Fetch user document from Firestore
    DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
        .collection(CollectionKey.USER_COLLECTION)
        .doc(user?.uid)
        .get();
    print("user value documents  ${userDoc.exists}");
    final cafaeteriaName = userDoc.data()?['cafeteriaName'] as String?;
    print("Cafateria nama is :${cafaeteriaName}");
    cafateriaAdminName = cafaeteriaName;
  }

  Future<void> _fetchCafeteriaMeals() async {
    isLoading.value = true;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isEmpty) {
      print("User not logged in");
      isLoading.value = false;
      return;
    }

    try {
      // ✅ Fetch meals once instead of using a stream
      List<MealModel> fetchedMeals =
          await cafaterisHistorySelectDateService.getMealsByUser(userId);

      // ✅ Update the observable list manually
      meals.value = fetchedMeals;
    } catch (e) {
      print("❌ Error fetching meals: $e");
    }

    isLoading.value = false;
  }

  // String checkIfDateHasMeal(DateTime day) {
  //   DateTime today = DateTime.now();
  //
  //   for (var child in childrenList) {
  //     if (child.selectedMealMenuData == null ||
  //         child.selectedMealMenuData!.isEmpty) {
  //       continue;
  //     }
  //
  //     DateTime orderDate;
  //     try {
  //       orderDate = DateTime.parse(child.date!);
  //       orderDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
  //     } catch (e) {
  //       print("Error parsing date: ${child.date}");
  //       continue;
  //     }
  //
  //     day = DateTime(day.year, day.month, day.day);
  //
  //     for (var mealData in child.selectedMealMenuData!) {
  //       var schedule = mealData.schedule;
  //
  //       if (schedule == null ||
  //           schedule.repeatOn == null ||
  //           (schedule.repeatEvery != 'week' && schedule.repeatEvery != 'month') ||
  //           schedule.repeatCount == null) {
  //         continue;
  //       }
  //
  //       String currentDayName = DateFormat('EEEE').format(day);
  //       List<String> scheduledDays =
  //       schedule.repeatOn!.map((d) => d.trim()).toList();
  //
  //       bool isDayScheduled = scheduledDays.contains(currentDayName);
  //
  //       if (isDayScheduled && day.compareTo(orderDate) >= 0) {
  //         int repeatCount = int.tryParse(schedule.repeatCount!) ?? 1;
  //
  //         if (schedule.repeatEvery == 'week') {
  //           int daysSinceStart = day.difference(orderDate).inDays;
  //           int weekNumber = daysSinceStart ~/ 7;
  //           if (weekNumber < repeatCount) {
  //             if (day.isAfter(DateTime.now())) {
  //               return "✔️ Meal Available •"; // Dot after the current date
  //             }
  //           }
  //         }
  //         else if (schedule.repeatEvery == 'month') {
  //           // Calculate months since start, including the initial month
  //           int monthsSinceStart = (day.year - orderDate.year) * 12 +
  //               (day.month - orderDate.month);
  //
  //           // Specific check for exact day match and within repeat count
  //           if (monthsSinceStart >= 0 && monthsSinceStart < repeatCount) {
  //             // Ensure the exact day matches the original order date
  //             if (day.day == orderDate.day &&
  //                 day.isAfter(DateTime.now())) {
  //               return "✔️ Meal Available •"; // Dot after the current date
  //             }
  //
  //             // Optional: Add a break or return to stop further checking
  //             // This prevents unnecessary iterations
  //             if (monthsSinceStart == repeatCount - 1) {
  //               break;
  //             }
  //           }
  //         }
  //
  //       }
  //     }
  //   }
  //   return "";
  // }
  String checkIfDateHasMeal(DateTime day) {
    // Normalize today's date for comparison
    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    // Normalize the day parameter for comparison
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);

    // Only check for meals on today or future dates
    if (normalizedDay.isBefore(normalizedToday)) {
      return ""; // No meal indicator for past dates
    }

    for (var child in childrenList) {
      if (child.selectedMealMenuData == null ||
          child.selectedMealMenuData!.isEmpty) {
        continue;
      }

      DateTime orderDate;
      try {
        orderDate = DateTime.parse(child.date!);
        orderDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
      } catch (e) {
        print("Error parsing date: ${child.date}");
        continue;
      }

      day = DateTime(day.year, day.month, day.day);

      for (var mealData in child.selectedMealMenuData!) {
        var schedule = mealData.schedule;

        if (schedule == null ||
            schedule.repeatOn == null ||
            (schedule.repeatEvery != 'week' &&
                schedule.repeatEvery != 'month') ||
            schedule.repeatCount == null) {
          continue;
        }

        String currentDayName = DateFormat('EEEE').format(day);
        List<String> scheduledDays =
            schedule.repeatOn!.map((d) => d.trim()).toList();

        bool isDayScheduled = scheduledDays.contains(currentDayName);

        if (isDayScheduled && day.compareTo(orderDate) >= 0) {
          int repeatCount = int.tryParse(schedule.repeatCount!) ?? 1;

          if (schedule.repeatEvery == 'week') {
            int daysSinceStart = day.difference(orderDate).inDays;
            int weekNumber = daysSinceStart ~/ 7;
            if (weekNumber < repeatCount) {
              if (day.isAfter(DateTime.now())) {
                return "✔️ Meal Available •"; // Dot after the current date
              }
            }
            // if (weekNumber < repeatCount) {
            //   return day.isAfter(DateTime.now()) ? "✔️ Meal Available •" : "✔️ Meal Available";
            // }
          } else if (schedule.repeatEvery == 'month') {
            // Calculate months since start, including the initial month
            int monthsSinceStart = (day.year - orderDate.year) * 12 +
                (day.month - orderDate.month);

            // Specific check for exact day match and within repeat count
            if (monthsSinceStart >= 0 && monthsSinceStart < repeatCount) {
              // Ensure the exact day matches the original order date
              if (day.isAfter(DateTime.now())) {
                return "✔️ Meal Available •"; // Dot after the current date
              }
            }
          }
        }
      }
    }
    return "";
  }

  ///Check if two dates are the same (ignores time)**
  bool isSameDay(DateTime date1, DateTime date2) {
    DateTime normalizedDate1 = DateTime(date1.year, date1.month, date1.day);
    DateTime normalizedDate2 = DateTime(date2.year, date2.month, date2.day);

    print("✅ Checking exact date match: $normalizedDate1 , $normalizedDate2");

    return normalizedDate1.isAtSameMomentAs(normalizedDate2);
  }

  ///Get weekday name from DateTime**
  String getWeekdayName(DateTime date) {
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][date.weekday - 1]
        .trim(); // Ensure correct indexing and remove any extra spaces
  }

  ///Get the next occurrence of a specific weekday after a given date**
  Future<void> fetchCafateriaChildren() async {
    isLoading.value = true;

    List<ParentsAddChildren> children = await cafaterisHistorySelectDateService
        .fetchChildrenByCafateriaName(cafateriaAdminName!);
    childrenList.assignAll(children);
    print("children data is  $children");
    await getUpcomingOrders(); // Call function after updating meals list

    isLoading.value = false;
    update(['cafateriaHistorySelectDataId']);
  }

  // Method to update the selected date and filter upcoming orders
  void updateSelectedDate(DateTime date) {
    // If the same date is selected again, toggle selection off
    if (isDateSelected.value && isSameDay(date, selectedDate.value)) {
      isDateSelected.value = false;
      selectedDate.value = DateTime.now(); // Reset to today
    } else {
      // Otherwise, select the new date
      selectedDate.value = date;
      isDateSelected.value = true;
    }

    // Refresh the upcoming orders list with the new date
    getUpcomingOrders();
    update(['cafateriaHistorySelectDataId']);
  }

  /// get the upcoming orders
  // Future<void> getUpcomingOrders() async {
  //   await Future.delayed(Duration(milliseconds: 1)); // Ensures async execution if needed
  //
  //   Map<String, Map<String, dynamic>> mealData = {};
  //
  //   DateTime today = DateTime.now();
  //
  //   for (var child in childrenList) {
  //     for (var meal in child.selectedMealMenuData ?? []) {
  //       var schedule = meal.schedule;
  //       if (schedule == null ||
  //           schedule.repeatOn == null ||
  //           (schedule.repeatEvery != 'week' && schedule.repeatEvery != 'month') ||
  //           schedule.repeatCount == null) {
  //         continue;
  //       }
  //
  //       DateTime orderDate;
  //       try {
  //         orderDate = DateTime.parse(child.date!);
  //         orderDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
  //       } catch (e) {
  //         print("Error parsing date: ${child.date}");
  //         continue;
  //       }
  //
  //       List<DateTime> futureOrderDates = [];
  //
  //       for (int i = 0; i < (int.tryParse(schedule.repeatCount!) ?? 1); i++) {
  //         if (schedule.repeatEvery == 'week') {
  //           futureOrderDates.add(orderDate.add(Duration(days: 7 * i)));
  //         } else if (schedule.repeatEvery == 'month') {
  //           futureOrderDates.add(DateTime(orderDate.year, orderDate.month + i, orderDate.day));
  //         }
  //         print("order month is ${orderDate.day}");
  //       }
  //
  //       // Check if this child has any future orders
  //       bool hasFutureOrder = futureOrderDates.any((date) => date.isAfter(today));
  //
  //       if (hasFutureOrder) {
  //         if (!mealData.containsKey(meal.mealName)) {
  //           mealData[meal.mealName] = {
  //             'count': 0,
  //             'image': meal.imageUrl,
  //             'studentIds': <String>[]
  //           };
  //         }
  //
  //         mealData[meal.mealName]!['count'] += 1;
  //         mealData[meal.mealName]!['studentIds'].add(child.id);
  //       }
  //     }
  //   }
  //
  //   List<String?> adminMeals = meals.map((data) => data.name).toList();
  //   upComingMealOrderList.clear();
  //
  //   for (var entry in mealData.entries) {
  //     String mealName = entry.key;
  //     int studentCount = entry.value['count'];
  //     String? mealImage = entry.value['image'];
  //     List<String> studentIds = (entry.value['studentIds'] as List<dynamic>?)?.cast<String>() ?? [];
  //
  //     bool isInAdminMeals = adminMeals.contains(mealName);
  //
  //     upComingMealOrderList.add(
  //       UpcomingMealOrder(
  //         image: mealImage,
  //         itemName: mealName,
  //         weekday: DateFormat('EEEE').format(DateTime.now()),
  //         expectedStudent: studentCount,
  //         studentIds: studentIds, // ✅ Now storing student IDs
  //       ),
  //     );
  //         print("🍽️ Meal: $mealName | Ordered by: $studentCount students | Exists in Admin Meals: $isInAdminMeals | Image: $mealImage");
  //
  //   }
  //
  //
  //   upComingMealOrderList.sort((a, b) => (b.expectedStudent ?? 0).compareTo(a.expectedStudent ?? 0));
  // }
  Future<void> getUpcomingOrders() async {
    await Future.delayed(Duration(milliseconds: 1)); // Ensures async execution

    Map<String, Map<String, dynamic>> mealData = {};
    DateTime today = DateTime.now();
    // Normalize today for comparison
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    print("🔍 Starting getUpcomingOrders() method");
    print("Current Date: $today");

    for (var child in childrenList) {
      for (var meal in child.selectedMealMenuData ?? []) {
        var schedule = meal.schedule;
        print("\n🍽️ Checking Meal: ${meal.mealName}");

        if (schedule == null ||
            schedule.repeatOn == null ||
            (schedule.repeatEvery != 'week' &&
                schedule.repeatEvery != 'month') ||
            schedule.repeatCount == null) {
          print("❌ Invalid schedule data, skipping meal: ${meal.mealName}");
          continue;
        }

        DateTime orderDate;
        try {
          orderDate = DateTime.parse(child.date!);
          orderDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
          print("📅 Order Date: $orderDate");
        } catch (e) {
          print("❌ Error parsing date: ${child.date}");
          continue;
        }

        print("🔁 Repeat Schedule:");
        print("  - Repeat Every: ${schedule.repeatEvery}");
        print("  - Repeat Count: ${schedule.repeatCount}");
        print("  - Repeat On: ${schedule.repeatOn}");

        List<DateTime> futureOrderDates = [];

        for (int i = 0; i < (int.tryParse(schedule.repeatCount!) ?? 0); i++) {
          DateTime futureDate;

          if (schedule.repeatEvery == 'week') {
            // Check all upcoming days in the current week
            for (int j = 0; j < 7; j++) {
              futureDate = orderDate.add(Duration(days: j));

              String futureDayName =
                  DateFormat('EEEE').format(futureDate).toLowerCase();
              List<dynamic> scheduledDays = schedule.repeatOn!
                  .map((d) => d.toLowerCase().trim())
                  .toList();

              print("\n🕰️ Checking Future Weekday: $futureDate");
              print("  - Future Day Name: $futureDayName");
              print("  - Scheduled Days: $scheduledDays");

              // Normalize future date for comparison
              DateTime normalizedFutureDate =
                  DateTime(futureDate.year, futureDate.month, futureDate.day);

              // Check if the date matches the selected date and is today or in the future
              bool dateMatches = isSameDay(futureDate, selectedDate.value);
              bool isCurrentOrFuture =
                  normalizedFutureDate.isAtSameMomentAs(normalizedToday) ||
                      normalizedFutureDate.isAfter(normalizedToday);

              if (dateMatches &&
                  scheduledDays.contains(futureDayName) &&
                  isCurrentOrFuture) {
                print(
                    "✅ Scheduled Meal Found on $futureDate (matches selected date)");
                futureOrderDates.add(futureDate);
              }
            }
          } else if (schedule.repeatEvery == 'month') {
            // Check all future occurrences in the current and next months
            for (int j = 0; j < 31; j++) {
              try {
                futureDate = DateTime(
                    orderDate.year, orderDate.month, orderDate.day + j);
              } catch (e) {
                continue; // Skip invalid dates
              }

              String futureDayName =
                  DateFormat('EEEE').format(futureDate).toLowerCase();
              List<dynamic> scheduledDays = schedule.repeatOn!
                  .map((d) => d.toLowerCase().trim())
                  .toList();

              print("\n🕰️ Checking Future Monthday: $futureDate");
              print("  - Future Day Name: $futureDayName");
              print("  - Scheduled Days: $scheduledDays");

              // Normalize future date for comparison
              DateTime normalizedFutureDate =
                  DateTime(futureDate.year, futureDate.month, futureDate.day);

              // Check if the date matches the selected date and is today or in the future
              bool dateMatches = isSameDay(futureDate, selectedDate.value);
              bool isCurrentOrFuture =
                  normalizedFutureDate.isAtSameMomentAs(normalizedToday) ||
                      normalizedFutureDate.isAfter(normalizedToday);

              if (dateMatches &&
                  scheduledDays.contains(futureDayName) &&
                  isCurrentOrFuture) {
                print(
                    "✅ Scheduled Meal Found on $futureDate (matches selected date)");
                futureOrderDates.add(futureDate);
                break; // Stop checking once we find a valid date
              }
            }
          }
        }

        print(
            "\n📋 Future Order Dates for ${meal.mealName}: $futureOrderDates");

        if (futureOrderDates.isNotEmpty) {
          if (!mealData.containsKey(meal.mealName)) {
            mealData[meal.mealName] = {
              'count': 0,
              'image': meal.imageUrl,
              'itemPrice': meal.mealPrice ?? "",
              'studentIds': <String>[]
            };
          }

          mealData[meal.mealName]!['count'] += 1;
          // Only add the child ID if it's not null
          if (child.id != null) {
            mealData[meal.mealName]!['studentIds'].add(child.id!);
          } else if (child.childId != null) {
            // Try to use childId as a fallback
            mealData[meal.mealName]!['studentIds'].add(child.childId!);
          }
          print("🏆 Meal Added to Order Data");
        }
      }
    }

    print("\n🍲 Final Meal Data: $mealData");

    // Clear the existing list before adding new data
    upComingMealOrderList.clear();

    List<String?> adminMeals = meals.map((data) => data.name).toList();

    for (var entry in mealData.entries) {
      String mealName = entry.key;
      int studentCount = entry.value['count'];
      String? mealImage = entry.value['image'];
      String? mealPrice = entry.value['itemPrice'];
      List<String> studentIds = [];
      // Safely handle the studentIds list
      if (entry.value['studentIds'] != null) {
        try {
          studentIds =
              (entry.value['studentIds'] as List<dynamic>).cast<String>();
        } catch (e) {
          print("Error casting studentIds: $e");
        }
      }

      bool isInAdminMeals = adminMeals.contains(mealName);
      String weekday = DateFormat('EEEE').format(DateTime.now());

      upComingMealOrderList.add(
        UpcomingMealOrder(
          image: mealImage,
          itemName: mealName,
          itemPrice: mealPrice,
          weekday: weekday,
          expectedStudent: studentCount,
          studentIds: studentIds, // ✅ Now storing student IDs
        ),
      );

      print(
          "🍽️ Meal: $mealName | Ordered by: $studentCount students | student Id $studentIds| Exists in Admin Meals: $isInAdminMeals | Image: $mealImage| price : $mealPrice");
    }

    // Sort the list in descending order by student count
    upComingMealOrderList.sort(
        (a, b) => (b.expectedStudent ?? 0).compareTo(a.expectedStudent ?? 0));

    print("✅ Sorted Meal List Updated!");
  }
  // Future<void> getUpcomingOrders() async {
  //   await Future.delayed(Duration(milliseconds: 1)); // Ensures async execution if needed
  //
  //   // Map to store meal data (count and image)
  //   Map<String, Map<String, dynamic>> mealData = {};
  //
  //   // Count how many children ordered each meal and store the image
  //   for (var child in childrenList) {
  //     for (var meal in child.selectedMealMenuData ?? []) {
  //       if (!mealData.containsKey(meal.mealName)) {
  //         mealData[meal.mealName] = {
  //           'count': 0,
  //           'image': meal.imageUrl, // Assuming meal.imageUrl holds the image link
  //         };
  //       }
  //       mealData[meal.mealName]!['count'] += 1;
  //     }
  //   }
  //
  //   // Get the list of admin meals
  //   List<String?> adminMeals = meals.map((data) => data.name).toList();
  //
  //   // Clear the existing list before adding new data
  //   upComingMealOrderList.clear();
  //
  //   // Add meals to the upcoming order list
  //   for (var entry in mealData.entries) {
  //     String mealName = entry.key;
  //     int studentCount = entry.value['count'];
  //     String? mealImage = entry.value['image']; // Get meal image
  //     bool isInAdminMeals = adminMeals.contains(mealName);
  //
  //     // Get current weekday (assuming order is for today)
  //     String weekday = DateFormat('EEEE').format(DateTime.now());
  //
  //     // Add data to the observable list
  //     upComingMealOrderList.add(
  //       UpcomingMealOrder(
  //         image: mealImage,
  //         itemName: mealName,
  //         weekday: weekday,
  //         expectedStudent: studentCount,
  //       ),
  //     );
  //
  //     // Debug print
  //     print("🍽️ Meal: $mealName | Ordered by: $studentCount students | Exists in Admin Meals: $isInAdminMeals | Image: $mealImage");
  //   }
  //   upComingMealOrderList.sort((a, b) => (b.expectedStudent??0).compareTo(a.expectedStudent??0));
  // }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
