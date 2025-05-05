import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class SelectableOptions extends StatelessWidget {
  final String title;
  final List<String> options;
  final RxString selectedOption; // Observable for selected option
  final bool isRowLayout; // Optional parameter for layout control
  final bool isSingleRow; // Optional parameter for layout control

  const SelectableOptions({
    Key? key,
    required this.title,
    required this.options,
    this.isSingleRow = false, // Default is false
    required this.selectedOption,
    this.isRowLayout = false, // Default is false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isRowLayout) {
      // Single-row layout
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Padding(
            padding: isSingleRow
                ? const EdgeInsets.only(left: 4)
                : const EdgeInsets.only(left: 12),
            child: Text(
              title,
              style: AppTextStyles.MetropolisLight.copyWith(
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ),
          // const SizedBox(width: 16), // Space between the title and options

          // Options in a horizontal row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Space options
              children: options.map((option) {
                return GestureDetector(
                  onTap: () {
                    // Update the selected option
                    selectedOption.value = option;
                  },
                  child: Row(
                    children: [
                      // Circular icon with Obx
                      const SizedBox(width: 8),
                      // Text for the option
                      Text(
                        option,
                        style: AppTextStyles.PoppinsRegular.copyWith(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(() {
                        return Container(
                          height: 18,
                          width: 18,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedOption.value == option
                                ? AppColors.gradientStartColor // Selected state
                                : Colors.transparent, // Unselected state
                            border: Border.all(
                              color: selectedOption.value == option
                                  ? const Color(0xFFE2E2E2) // Selected border
                                  : const Color(
                                      0xFFE2E2E2), // Unselected border
                            ),
                          ),
                          child: Icon(
                            selectedOption.value == option
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: Colors.transparent, // Transparent background
                            size: 10,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      // Default vertical layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: AppTextStyles.MetropolisMedium.copyWith(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12), // Space between title and options

          // Options in a Row
          Row(
            children: options.map((option) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Update the selected option
                    selectedOption.value = option;
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular icon using Obx for state

                      const SizedBox(width: 24),

                      Obx(() {
                        return Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedOption.value == option
                                ? AppColors.gradientStartColor // Selected state
                                : Colors.transparent, // Unselected state
                            border: Border.all(
                              color: selectedOption.value == option
                                  ? const Color(0xFFE2E2E2) // Selected border
                                  : const Color(
                                      0xFFE2E2E2), // Unselected border
                            ),
                          ),
                          child: Icon(
                            selectedOption.value == option
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: Colors.transparent, // Transparent background
                            size: 10,
                          ),
                        );
                      }),
                      const SizedBox(
                          width: 16), // Space between the icon and text

                      // Option Text
                      Text(
                        option,
                        style: AppTextStyles.MetropolisRegular.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      // Flexible(
                      //   child:
                      // ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
  }
}
