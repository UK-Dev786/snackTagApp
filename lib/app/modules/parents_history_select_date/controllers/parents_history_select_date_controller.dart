import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snacktag/models/cefeteria_admin/meal_model.dart';
import 'package:snacktag/models/cefeteria_admin/upcoming_meal_order.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';
import 'package:snacktag/services/parents/parents_history_select_date_service.dart';

class ParentsHistorySelectDateController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ParentsHistorySelectDateService parentsHistorySelectDateService =
      ParentsHistorySelectDateService();

  //TODO: Implement CafeteriaHistorySelectDateController

  final count = 0.obs;
  var isLoading = false.obs;
  String? cafateriaAdminName;
  var childrenList = <ParentsAddChildren>[].obs;
  var meals = <MealModel>[].obs;
  var upComingMealOrderList = <UpcomingMealOrder>[].obs;
  var filteredUpComingMealOrderList = <UpcomingMealOrder>[].obs;
  var selectedDate = DateTime.now().obs;
  var isDateSelected = false.obs;
  var parentAddWalletModel =
      Rxn<ParentAddWalletModel>(); // Observable wallet model

  @override
  void onInit() {
    // await fetchCafeteriaName();
    listenToWalletChanges(); // Start listening for real-time updates

    fetchParentsChildren();
    _fetchCafeteriaMeals();

    super.onInit();
  }

  void listenToWalletChanges() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("❌ No logged-in user found.");
      return;
    }

    print("🚀 Listening for wallet updates for Parent ID: ${currentUser.uid}");

    parentsHistorySelectDateService
        .fetchWalletStreamByParentId(currentUser.uid)
        .listen(
      (wallet) {
        if (wallet != null) {
          parentAddWalletModel.value = wallet as ParentAddWalletModel;
        }
        print("🔄 Wallet data updated: ${wallet?.toString()}");
      },
      onError: (error) {
        print("❌ Error fetching wallet data: $error");
      },
    );
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
          await parentsHistorySelectDateService.getMealsByUser(userId);

      // ✅ Update the observable list manually
      meals.value = fetchedMeals;
    } catch (e) {
      print("❌ Error fetching meals: $e");
    }

    isLoading.value = false;
  }

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

      for (var mealData in child.selectedMealMenuData!) {
        var schedule = mealData.schedule;

        if (schedule == null ||
            schedule.repeatOn == null ||
            (schedule.repeatEvery != 'week' &&
                schedule.repeatEvery != 'month') ||
            schedule.repeatCount == null) {
          continue;
        }

        String currentDayName = DateFormat('EEEE').format(normalizedDay);
        List<String> scheduledDays =
            schedule.repeatOn!.map((d) => d.trim()).toList();

        bool isDayScheduled = scheduledDays.contains(currentDayName);

        if (isDayScheduled && normalizedDay.compareTo(orderDate) >= 0) {
          int repeatCount = int.tryParse(schedule.repeatCount!) ?? 1;

          if (schedule.repeatEvery == 'week') {
            int daysSinceStart = normalizedDay.difference(orderDate).inDays;
            int weekNumber = daysSinceStart ~/ 7;
            if (weekNumber < repeatCount) {
              // Show indicator for today and future dates
              if (normalizedDay.isAtSameMomentAs(normalizedToday) ||
                  normalizedDay.isAfter(normalizedToday)) {
                return "✔️ Meal Available •"; // Dot after the current date
              }
            }
          } else if (schedule.repeatEvery == 'month') {
            // Calculate months since start, including the initial month
            int monthsSinceStart = (normalizedDay.year - orderDate.year) * 12 +
                (normalizedDay.month - orderDate.month);

            // Specific check for exact day match and within repeat count
            if (monthsSinceStart >= 0 && monthsSinceStart < repeatCount) {
              // Show indicator for today and future dates
              if (normalizedDay.isAtSameMomentAs(normalizedToday) ||
                  normalizedDay.isAfter(normalizedToday)) {
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
  Future<void> fetchParentsChildren() async {
    isLoading.value = true;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    if (userId.isEmpty) {
      print("User not logged in");
      isLoading.value = false;
      return;
    }
    List<ParentsAddChildren> children =
        await parentsHistorySelectDateService.fetchChildrenByParentId(userId);
    childrenList.assignAll(children);
    print("children data lenght  ${children.length}");
    await getUpcomingOrders(); // Call function after updating meals list

    isLoading.value = false;
    update(['parentsHistorySelectDataId']);
  }

  Future<void> getUpcomingOrders() async {
    await Future.delayed(Duration(milliseconds: 1));

    Map<String, Map<String, dynamic>> mealData = {};
    DateTime today = DateTime.now();
    // Normalize today to compare only year, month, and day
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);
    List<DateTime> futureOrderDates = [];

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

        // Clear futureOrderDates for each meal
        futureOrderDates = [];

        for (int i = 0; i < (int.tryParse(schedule.repeatCount!) ?? 0); i++) {
          DateTime futureDate;

          if (schedule.repeatEvery == 'week') {
            // Check all upcoming days in the current week
            for (int j = 0; j < 7; j++) {
              futureDate = orderDate.add(Duration(days: j));
              // Normalize future date to compare only year, month, and day
              DateTime normalizedFutureDate =
                  DateTime(futureDate.year, futureDate.month, futureDate.day);

              String futureDayName =
                  DateFormat('EEEE').format(futureDate).toLowerCase();
              List<dynamic> scheduledDays = (schedule.repeatOn ?? [])
                  .map((d) => d.toString().toLowerCase().trim())
                  .toList();

              print("\n🕰️ Checking Future Weekday: $futureDate");
              print("  - Future Day Name: $futureDayName");
              print("  - Scheduled Days: $scheduledDays");

              // Check if the date is today or in the future
              if ((normalizedFutureDate.isAtSameMomentAs(normalizedToday) ||
                      normalizedFutureDate.isAfter(normalizedToday)) &&
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
                // Normalize future date to compare only year, month, and day
                DateTime normalizedFutureDate =
                    DateTime(futureDate.year, futureDate.month, futureDate.day);

                String futureDayName =
                    DateFormat('EEEE').format(futureDate).toLowerCase();
                List<dynamic> scheduledDays = (schedule.repeatOn ?? [])
                    .map((d) => d.toString().toLowerCase().trim())
                    .toList();

                print("\n🕰️ Checking Future Monthday: $futureDate");
                print("  - Future Day Name: $futureDayName");
                print("  - Scheduled Days: $scheduledDays");

                // Check if the date is today or in the future
                if ((normalizedFutureDate.isAtSameMomentAs(normalizedToday) ||
                        normalizedFutureDate.isAfter(normalizedToday)) &&
                    scheduledDays.contains(futureDayName)) {
                  print("✅ Scheduled Meal Found on $futureDate");
                  futureOrderDates.add(futureDate);
                  break; // Stop checking once we find a valid date
                }
              } catch (e) {
                continue; // Skip invalid dates
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
              'studentIds': <dynamic>[], // Initialize as dynamic list
              'orderDate':
                  futureOrderDates.first // Store the earliest order date
            };
          }

          mealData[meal.mealName]!['count'] += 1;

          // Get the existing studentIds list
          var studentIds =
              mealData[meal.mealName]!['studentIds'] as List<dynamic>;
          // Add the new ID
          studentIds.add(child.id?.toString() ?? '');
          // Update the map with the new list
          mealData[meal.mealName]!['studentIds'] = studentIds;
        }
      }
    }

    print("\n🍲 Final Meal Data: $mealData");

    // Clear existing list
    upComingMealOrderList.clear();

    for (var entry in mealData.entries) {
      String mealName = entry.key;
      int studentCount = entry.value['count'];
      String? mealImage = entry.value['image'];
      String? mealPrice = entry.value['itemPrice'];
      DateTime orderDate = entry.value['orderDate'] ?? DateTime.now();

      // Safe casting of studentIds
      List<String> studentIds = [];
      if (entry.value['studentIds'] != null) {
        studentIds = (entry.value['studentIds'] as List)
            .map((item) => item.toString())
            .toList();
      }

      upComingMealOrderList.add(
        UpcomingMealOrder(
          image: mealImage,
          itemName: mealName,
          weekday:
              DateFormat('EEEE').format(orderDate), // Use the actual order date
          itemPrice: mealPrice,
          expectedStudent: studentCount,
          studentIds: studentIds,
        ),
      );

      print("🍽️ Meal: $mealName | Ordered by: $studentCount students | "
          "student Ids: $studentIds | Image: $mealImage | price: $mealPrice");
    }

    // Sort the list
    upComingMealOrderList.sort(
        (a, b) => (b.expectedStudent ?? 0).compareTo(a.expectedStudent ?? 0));
    update(['parentsHistorySelectDataId']);

    print("✅ Sorted Meal List Updated!");
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // If the same date is selected again, toggle selection off
    if (isDateSelected.value && isSameDay(selectedDay, selectedDate.value)) {
      isDateSelected.value = false;
      filteredUpComingMealOrderList.clear();
    } else {
      // Otherwise, select the new date
      selectedDate.value = selectedDay;
      isDateSelected.value = true;
      filterOrdersByDate(selectedDay);
    }
    update(['parentsHistorySelectDataId']);
  }

  void filterOrdersByDate(DateTime date) {
    filteredUpComingMealOrderList.clear();

    // Normalize the date to compare only year, month, and day
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    // Get today's date normalized for comparison
    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    // Only proceed if the selected date is today or in the future
    if (normalizedDate.isBefore(normalizedToday)) {
      return;
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
        continue;
      }

      for (var mealData in child.selectedMealMenuData!) {
        var schedule = mealData.schedule;

        if (schedule == null ||
            schedule.repeatOn == null ||
            (schedule.repeatEvery != 'week' &&
                schedule.repeatEvery != 'month') ||
            schedule.repeatCount == null) {
          continue;
        }

        String currentDayName = DateFormat('EEEE').format(normalizedDate);
        List<String> scheduledDays =
            schedule.repeatOn!.map((d) => d.trim()).toList();

        bool isDayScheduled = scheduledDays.contains(currentDayName);

        if (isDayScheduled && normalizedDate.compareTo(orderDate) >= 0) {
          int repeatCount = int.tryParse(schedule.repeatCount!) ?? 1;

          bool isValidOrder = false;

          if (schedule.repeatEvery == 'week') {
            int daysSinceStart = normalizedDate.difference(orderDate).inDays;
            int weekNumber = daysSinceStart ~/ 7;
            if (weekNumber < repeatCount) {
              isValidOrder = true;
            }
          } else if (schedule.repeatEvery == 'month') {
            int monthsSinceStart = (normalizedDate.year - orderDate.year) * 12 +
                (normalizedDate.month - orderDate.month);
            if (monthsSinceStart >= 0 && monthsSinceStart < repeatCount) {
              isValidOrder = true;
            }
          }

          if (isValidOrder) {
            // Check if this meal is already in the filtered list
            int existingIndex = filteredUpComingMealOrderList
                .indexWhere((order) => order.itemName == mealData.mealName);

            if (existingIndex != -1) {
              // Update existing entry
              UpcomingMealOrder existingOrder =
                  filteredUpComingMealOrderList[existingIndex];
              List<String> updatedStudentIds =
                  List<String>.from(existingOrder.studentIds ?? []);

              if (!updatedStudentIds.contains(child.id?.toString() ?? '')) {
                updatedStudentIds.add(child.id?.toString() ?? '');
              }

              filteredUpComingMealOrderList[existingIndex] = UpcomingMealOrder(
                image: existingOrder.image,
                itemName: existingOrder.itemName,
                weekday: DateFormat('EEEE').format(normalizedDate),
                itemPrice: existingOrder.itemPrice,
                expectedStudent: (existingOrder.expectedStudent ?? 0) + 1,
                studentIds: updatedStudentIds,
              );
            } else {
              // Add new entry
              filteredUpComingMealOrderList.add(
                UpcomingMealOrder(
                  image: mealData.imageUrl,
                  itemName: mealData.mealName,
                  weekday: DateFormat('EEEE').format(normalizedDate),
                  itemPrice: mealData.mealPrice,
                  expectedStudent: 1,
                  studentIds: [child.id?.toString() ?? ''],
                ),
              );
            }
          }
        }
      }
    }

    // Sort the filtered list
    filteredUpComingMealOrderList.sort(
        (a, b) => (b.expectedStudent ?? 0).compareTo(a.expectedStudent ?? 0));
  }

  void increment() => count.value++;
}
