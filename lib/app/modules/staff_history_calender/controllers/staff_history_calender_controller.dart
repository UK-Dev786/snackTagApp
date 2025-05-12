import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/cefeteria_admin/upcoming_meal_order.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/cefeteria_admin_services/cafateria_history_selectdate_service.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/services/staff_services/staff_history_calendar_service.dart';

class StaffHistoryCalenderController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StaffHistoryCalendarService staffHistoryCalendarService =
      StaffHistoryCalendarService();

  //TODO: Implement CafeteriaHistorySelectDateController

  final count = 0.obs;
  var isLoading = false.obs;
  String? cafateriaAdminName;
  String? cafateriaAdminId;

  var childrenList = <ParentsAddChildren>[].obs;
  var meals = <MealModel>[].obs;
  var upComingMealOrderList = <UpcomingMealOrder>[].obs;
  // Add Rx variable to store user data
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  @override
  void onInit() async {
    super.onInit();

    print("DEBUG: Initializing StaffHistoryCalenderController");
    isLoading.value = true;

    try {
      await fetchCafateriaName();
      if (cafateriaAdminName != null) {
        await fetchCafateriaChildren();
        await _fetchCafeteriaMeals();
      } else {
        print("ERROR: Cafeteria name is null, cannot fetch children or meals");
      }
    } catch (e) {
      print("ERROR: Exception in onInit: ${e.toString()}");
    } finally {
      isLoading.value = false;
      update(['staffHistorySelectDataId']);
      print("DEBUG: StaffHistoryCalenderController initialization complete");
    }
  }

  Future<void> fetchCafateriaName() async {
    try {
      print("DEBUG: Starting fetchCafateriaName()");
      final UserPreferences preferences = UserPreferences();
      StaffModel? staffData = await preferences.getStaffDataPreference();

      if (staffData == null) {
        print("ERROR: No stored staff data found");
        return;
      }

      print("DEBUG: Staff data found with ID: ${staffData.userId}");
      print("DEBUG: Staff data: ${staffData.toMap()}");

      if (staffData.userId == null || staffData.userId!.isEmpty) {
        print("ERROR: Staff userId is null or empty");
        return;
      }

      // Get the staff document using the stored staff ID
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection(CollectionKey.USER_COLLECTION)
          .doc(staffData.userId)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        print(
            "ERROR: User document doesn't exist or is null for ID: ${staffData.userId}");
        return;
      }

      print("DEBUG: Full document data: ${userDoc.data()}");
      userData.value = userDoc.data()!;

      final cafaeteriaName = userDoc.data()?['cafeteriaName'] as String?;
      print("DEBUG: Cafeteria name from document: $cafaeteriaName");

      if (cafaeteriaName == null || cafaeteriaName.isEmpty) {
        print("ERROR: Cafeteria name is null or empty");
        return;
      }

      cafateriaAdminName = cafaeteriaName;
      print(
          "DEBUG: Successfully set cafateriaAdminName to: $cafateriaAdminName");
    } catch (e) {
      print("ERROR: Error fetching cafeteria name: $e");
    }
  }

  Future<void> _fetchCafeteriaMeals() async {
    isLoading.value = true;

    // Debug the userData map to see what fields are available
    print("DEBUG: userData map contains: ${userData.value.keys}");
    print("DEBUG: Full userData: ${userData.value}");

    // Try both 'userID' and 'userId' fields
    cafateriaAdminId = userData.value['userId'] as String?;

    if (cafateriaAdminId == null || cafateriaAdminId!.isEmpty) {
      print("ERROR: cafateriaAdminId is null or empty");
      isLoading.value = false;
      return;
    }

    print("DEBUG: Using cafateriaAdminId: $cafateriaAdminId");

    try {
      // ✅ Fetch meals once instead of using a stream
      List<MealModel> fetchedMeals =
          await staffHistoryCalendarService.getMealsByUser(cafateriaAdminId!);

      // ✅ Update the observable list manually
      meals.value = fetchedMeals;
    } catch (e) {
      print("❌ Error fetching meals: $e");
    }

    isLoading.value = false;
  }

  String checkIfDateHasMeal(DateTime day) {
    DateTime today = DateTime.now();

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

    try {
      print("DEBUG: Fetching children for cafeteria: $cafateriaAdminName");

      if (cafateriaAdminName == null || cafateriaAdminName!.isEmpty) {
        print("ERROR: Cafeteria name is null or empty, cannot fetch children");
        return;
      }

      List<ParentsAddChildren> children = await staffHistoryCalendarService
          .fetchChildrenByCafateriaName(cafateriaAdminName!);

      print(
          "DEBUG: Found ${children.length} children for cafeteria: $cafateriaAdminName");

      childrenList.assignAll(children);

      if (children.isNotEmpty) {
        await getUpcomingOrders(); // Call function after updating meals list
      } else {
        print("DEBUG: No children found, skipping getUpcomingOrders()");
        upComingMealOrderList.clear(); // Ensure the list is empty
      }
    } catch (e) {
      print("ERROR: Exception in fetchCafateriaChildren: ${e.toString()}");
      upComingMealOrderList
          .clear(); // Ensure the list is empty in case of error
    } finally {
      isLoading.value = false;
      update(['staffHistorySelectDataId']);
    }
  }

  /// get the upcoming orders

  Future<void> getUpcomingOrders() async {
    await Future.delayed(Duration(milliseconds: 1)); // Ensures async execution

    Map<String, Map<String, dynamic>> mealData = {};
    DateTime today = DateTime.now();

    print("DEBUG: Starting getUpcomingOrders() method");
    print("DEBUG: Current Date: $today");
    print("DEBUG: Number of children in childrenList: ${childrenList.length}");

    if (childrenList.isEmpty) {
      print("ERROR: No children found for this cafeteria");
      return;
    }

    for (var child in childrenList) {
      print("\nDEBUG: Processing child: ${child.childName} (ID: ${child.id})");
      print(
          "DEBUG: Child has ${child.selectedMealMenuData?.length ?? 0} selected meals");

      if (child.selectedMealMenuData == null ||
          child.selectedMealMenuData!.isEmpty) {
        print("DEBUG: Child has no selected meals, skipping");
        continue;
      }

      for (var meal in child.selectedMealMenuData!) {
        var schedule = meal.schedule;
        print("\nDEBUG: Checking Meal: ${meal.mealName}");

        if (schedule == null ||
            schedule.repeatOn == null ||
            (schedule.repeatEvery != 'week' &&
                schedule.repeatEvery != 'month') ||
            schedule.repeatCount == null) {
          print(
              "DEBUG: Invalid schedule data, skipping meal: ${meal.mealName}");
          continue;
        }

        DateTime orderDate;
        try {
          if (child.date == null) {
            print("DEBUG: Child date is null, skipping meal: ${meal.mealName}");
            continue;
          }

          orderDate = DateTime.parse(child.date!);
          orderDate = DateTime(orderDate.year, orderDate.month, orderDate.day);
          print("DEBUG: Order Date: $orderDate");
        } catch (e) {
          print("ERROR: Error parsing date: ${child.date} - ${e.toString()}");
          continue;
        }

        print("DEBUG: Repeat Schedule:");
        print("DEBUG:   - Repeat Every: ${schedule.repeatEvery}");
        print("DEBUG:   - Repeat Count: ${schedule.repeatCount}");
        print("DEBUG:   - Repeat On: ${schedule.repeatOn}");

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

              if (futureDate.isAfter(today) &&
                  scheduledDays.contains(futureDayName)) {
                print("✅ Scheduled Meal Found on $futureDate");
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

              if (futureDate.isAfter(today) &&
                  scheduledDays.contains(futureDayName)) {
                print("✅ Scheduled Meal Found on $futureDate");
                futureOrderDates.add(futureDate);
                break; // Stop checking once we find a valid date
              }
            }
          }
        }

        print(
            "\n📋 Future Order Dates for ${meal.mealName}: $futureOrderDates");

        if (futureOrderDates.isNotEmpty && meal.mealName != null) {
          String mealNameKey =
              meal.mealName!; // Convert nullable String? to non-nullable String

          if (!mealData.containsKey(mealNameKey)) {
            mealData[mealNameKey] = {
              'count': 0,
              'image': meal.imageUrl,
              'studentIds': <String>[]
            };
          }

          mealData[mealNameKey]!['count'] += 1;

          // Always add the child ID to the studentIds list
          if (child.id != null) {
            // Only add the student ID if it's not already in the list
            if (!mealData[mealNameKey]!['studentIds'].contains(child.id!)) {
              mealData[mealNameKey]!['studentIds'].add(child.id!);
              print(
                  "DEBUG: Added student ID ${child.id} to meal ${meal.mealName}");
            }
          } else {
            print("DEBUG: Child ID is null, cannot add to studentIds list");
          }

          // If we have no student IDs but we have a count, create dummy IDs
          if (mealData[mealNameKey]!['studentIds'].isEmpty &&
              mealData[mealNameKey]!['count'] > 0) {
            // Create dummy IDs equal to the expectedStudent count
            int expectedCount = mealData[mealNameKey]!['count'];
            print(
                "DEBUG: Creating $expectedCount dummy student IDs for meal ${meal.mealName}");

            // Clear any existing student IDs
            mealData[mealNameKey]!['studentIds'] = <String>[];

            // Add the correct number of dummy student IDs
            for (int i = 0; i < expectedCount; i++) {
              mealData[mealNameKey]!['studentIds'].add("student_$i");
              print(
                  "DEBUG: Added dummy student ID student_$i to meal ${meal.mealName}");
            }
          }

          print("DEBUG: Meal Added to Order Data: ${mealNameKey}");
          print(
              "DEBUG: Current studentIds: ${mealData[mealNameKey]!['studentIds']}");
          print("DEBUG: Current count: ${mealData[mealNameKey]!['count']}");
        }
      }
    }

    print("\n🍲 Final Meal Data: $mealData");

    // Clear the existing list before adding new data
    upComingMealOrderList.clear();

    List<String?> adminMeals = meals.map((data) => data.name).toList();

    print("DEBUG: Number of meals in mealData: ${mealData.entries.length}");
    print("DEBUG: Admin meals: $adminMeals");

    for (var entry in mealData.entries) {
      String mealName = entry.key;
      int studentCount = entry.value['count'];
      String? mealImage = entry.value['image'];
      List<String> studentIds =
          (entry.value['studentIds'] as List<dynamic>?)?.cast<String>() ?? [];

      bool isInAdminMeals = adminMeals.contains(mealName);
      String weekday = DateFormat('EEEE').format(DateTime.now());

      print("DEBUG: Adding meal to upComingMealOrderList: $mealName");
      print("DEBUG: Student count: $studentCount");
      print("DEBUG: Student IDs: $studentIds");

      // Make sure we have the correct number of student IDs
      if (studentIds.length != studentCount) {
        print(
            "DEBUG: Mismatch between studentIds.length (${studentIds.length}) and studentCount ($studentCount)");

        // If we have fewer student IDs than the count, add dummy IDs
        if (studentIds.length < studentCount) {
          int missingCount = studentCount - studentIds.length;
          print("DEBUG: Adding $missingCount more dummy student IDs");

          for (int i = 0; i < missingCount; i++) {
            studentIds.add("student_${studentIds.length}");
          }
        }
      }

      print("DEBUG: Final studentIds.length: ${studentIds.length}");

      upComingMealOrderList.add(
        UpcomingMealOrder(
          image: mealImage,
          itemName: mealName,
          weekday: weekday,
          expectedStudent: studentCount,
          studentIds: studentIds,
        ),
      );

      print(
          "DEBUG: Meal: $mealName | Ordered by: $studentCount students | Student IDs: $studentIds | Exists in Admin Meals: $isInAdminMeals | Image: $mealImage");
    }

    print(
        "DEBUG: Final upComingMealOrderList length: ${upComingMealOrderList.length}");

    // Sort the list in descending order by actual student count (length of studentIds)
    upComingMealOrderList.sort((a, b) =>
        (b.studentIds?.length ?? 0).compareTo(a.studentIds?.length ?? 0));

    print("✅ Sorted Meal List Updated!");
  }

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
