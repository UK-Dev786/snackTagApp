import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/reuse_button.dart';

class ScheduleSelectedDialogController extends GetxController {
  final RxInt repeatCount = 1.obs;
  final RxString repeatUnit = 'day'.obs;
  final RxList<bool> selectedDays = List.generate(7, (index) => index == 0).obs;
  final RxList<bool> selectedTimes = List.generate(9, (index) => false).obs;

  // Show day selection for both week and month
  bool get showDaySelection =>
      repeatUnit.value.contains('week') ||
          repeatUnit.value.contains('month') ||
          repeatUnit.value.contains('day');

  // List of available times
  List<String> get availableTimes => [
    '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm', '5pm'
  ];

  String get currentRepeatUnit {
    return repeatCount.value > 1 ? '${repeatUnit.value}s' : repeatUnit.value;
  }

  void incrementCount() {
    if (repeatCount.value < 99) {
      repeatCount.value++;
    }
  }

  void decrementCount() {
    if (repeatCount.value > 1) {
      repeatCount.value--;
    }
  }

  void toggleDay(int index) {
    if (index < selectedDays.length) {
      selectedDays[index] = !selectedDays[index];
      selectedDays.refresh();
    }
  }

  void toggleTime(int index) {
    if (index < selectedTimes.length) {
      selectedTimes[index] = !selectedTimes[index];
      selectedTimes.refresh();
    }
  }

  void updateRepeatUnit(String? value) {
    if (value != null) {
      repeatUnit.value = value.replaceAll('s', '');
      if (value.contains('day')) {
        selectedDays.value = List.generate(7, (index) => false);
      }
    }
  }

  Map<String, dynamic> getSelectedScheduleData() {
    return {
      'repeatCount': repeatCount.value,
      'repeatUnit': currentRepeatUnit,
      'selectedDays': showDaySelection ? selectedDays.toList() : [],
    };
  }
}

class CustomScheduleDialog extends StatelessWidget {
  final Function(String) onScheduleSelected;
  final controller = Get.find<ScheduleSelectedDialogController>();

  CustomScheduleDialog({required this.onScheduleSelected});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double defaultPadding = 16.0;

    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: screenSize.width - 32,
        height: screenSize.height * 0.50,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Schedule',
              style: AppTextStyles.MetropolisBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: defaultPadding),

            // Available Time Section
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available at',
                  style:
                  AppTextStyles.MetropolisRegular.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        controller.availableTimes.length,
                            (index) {
                          bool isSelected = index < controller.selectedTimes.length
                              ? controller.selectedTimes[index]
                              : false;

                          return GestureDetector(
                            onTap: () => controller.toggleTime(index),
                            child: Container(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFF3E0)
                                    : const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF9A0D)
                                      : Colors.grey.shade400,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                controller.availableTimes[index],
                                style: AppTextStyles.MetropolisRegular
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )),

            // Repeat on Section
            Obx(() => Column(
              children: [
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Repeat on',
                      style: AppTextStyles.MetropolisRegular.copyWith(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .asMap()
                      .entries
                      .map(
                        (entry) => GestureDetector(
                      onTap: () => controller.toggleDay(entry.key),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: controller.selectedDays[entry.key]
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFF2F2F2),
                          border: Border.all(
                            color: controller.selectedDays[entry.key]
                                ? const Color(0xFFFF9A0D)
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          entry.value,
                          style: AppTextStyles.PoppinsRegular
                              .copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            )),

            const Spacer(),

            // Confirm Button
            CustomButton(
              text: 'Confirm',
              onPressed: () {
                final selectedTimes = controller.selectedTimes
                    .asMap()
                    .entries
                    .where((entry) => entry.value)
                    .map((entry) => controller.availableTimes[entry.key])
                    .join(', ');

                final selectedDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                    .asMap()
                    .entries
                    .where((entry) => controller.selectedDays[entry.key])
                    .map((entry) => entry.value)
                    .join(', ');

                String scheduleSummary =
                    "Available at: $selectedTimes | Repeat on: $selectedDays";

                onScheduleSelected(scheduleSummary);

                Navigator.of(context).pop();
              },
              isLoading: false.obs,
            ),
          ],
        ),
      ),
    );
  }
}
