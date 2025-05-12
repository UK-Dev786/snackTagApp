import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_shedule_dialog.dart';

import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cafeteria_meal_details_controller.dart';

class CafeteriaMealDetailsView extends GetView<CafeteriaMealDetailsController> {
  const CafeteriaMealDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(AppImages.back, height: 15, width: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                AppImages.authImg,
                height: 80,
              ),
            ),
            const SizedBox(height: 35),
            Align(
              alignment: Alignment.center,
              child: Text(
                'MEAL DETAILS',
                style: AppTextStyles.MetropolisMedium.copyWith(
                    color: const Color(0xFF434343), fontSize: 18),
              ),
            ),
            const SizedBox(height: 36),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Obx(() {
                          return Container(
                            width: double.infinity,
                            height: 127,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20), // Apply radius to image
                              child: controller.selectedImage.value != null
                                  ? Image.file(
                                      controller.selectedImage.value!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 127,
                                    )
                                  : controller.imageUrl.value.isNotEmpty
                                      ? Image.network(
                                          controller.imageUrl.value,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 127,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return _buildPlaceholder();
                                          },
                                        )
                                      : _buildPlaceholder(),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      SimpleTextFieldWithOutSuffixWidget(
                          controller: controller.nameController,
                          hintText: 'Meal Name'),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              20), // Apply radius to image
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Obx(() => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value:
                                        controller.selectedAvailability.value,
                                    hint: Text(
                                      'Availability',
                                      style: AppTextStyles.MetropolisRegular
                                          .copyWith(
                                        fontSize: 14,
                                        color: const Color(0xFFB6B7B7),
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Color(0xFFB6B7B7)),
                                    items: <String>['available', 'unavailable']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value.capitalize!,
                                          style: AppTextStyles.MetropolisRegular
                                              .copyWith(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      controller.selectedAvailability.value =
                                          newValue!;
                                    },
                                  ),
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SimpleTextFieldWithOutSuffixWidget(
                        hintText: "Available",
                        isReadOnly: true,
                        controller: controller.availableTimeDateController,
                        keyboardType: TextInputType.none,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CustomScheduleDialog(
                                onScheduleSelected: (String selectedSchedule) {
                                  // Split the string using '|' as the separator
                                  List<String> parts =
                                      selectedSchedule.split('|');

                                  // Extract Available at
                                  String availableAt = parts[0]
                                      .replaceFirst("Available at:", "")
                                      .trim();

                                  // Extract Repeat on
                                  String repeatOn = parts.length > 1
                                      ? parts[1]
                                          .replaceFirst("Repeat on:", "")
                                          .trim()
                                      : "";

                                  // Print the separated values
                                  print("Available at: $availableAt");
                                  print("Repeat on: $repeatOn");
                                  controller.availableTimeDateController.text =
                                      selectedSchedule;

                                  controller.availableAt = availableAt
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();
                                  controller.repeatOn = repeatOn
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SimpleTextFieldWithOutSuffixWidget(
                        controller: controller.priceController,
                        hintText: 'Price',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      SimpleTextFieldWithOutSuffixWidget(
                        controller: controller.descriptionController,
                        hintText: 'Description',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Nutritional Facts",
                                  style: AppTextStyles.MetropolisBold.copyWith(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "(Optional)",
                                  style:
                                      AppTextStyles.MetropolisRegular.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Two columns layout for nutritional facts
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left column
                                Expanded(
                                  child: Column(
                                    children: [
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller:
                                            controller.caloriesController,
                                        hintText: 'Calories (kcal)',
                                      ),
                                      SizedBox(height: 8),
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller:
                                            controller.proteinController,
                                        hintText: 'Protein (grams)',
                                      ),
                                      SizedBox(height: 8),
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller: controller.fatController,
                                        hintText: 'Fat (grams)',
                                      ),
                                      SizedBox(height: 8),
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller:
                                            controller.saturatedFatController,
                                        hintText: 'Saturated Fat (grams)',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Right column
                                Expanded(
                                  child: Column(
                                    children: [
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller:
                                            controller.carbohydratesController,
                                        hintText: 'Carbs (grams)',
                                      ),
                                      SizedBox(height: 8),
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller: controller.fiberController,
                                        hintText: 'Fiber (grams)',
                                      ),
                                      SizedBox(height: 8),
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller: controller.sugarsController,
                                        hintText: 'Sugars (grams)',
                                      ),
                                      SizedBox(height: 8),
                                      SimpleTextFieldWithOutSuffixWidget(
                                        controller: controller.sodiumController,
                                        hintText: 'Sodium (mg)',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Cholesterol in a separate row for balance
                            SimpleTextFieldWithOutSuffixWidget(
                              controller: controller.cholesterolController,
                              hintText: 'Cholesterol (mg)',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Wrapping the CustomButton with Obx to listen to controller's isLoading value
                      Obx(
                        () => CustomButton1(
                            text: 'SUBMIT',
                            onPressed: controller.submitMeal,
                            isLoading: controller
                                .isLoading.value // Reactive loading indicator
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder Widget Function
// Placeholder Widget Function
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon/camera.png', width: 60, height: 50),
        const SizedBox(height: 10),
        Text(
          'Upload Meal Photo',
          style: AppTextStyles.MetropolisRegular.copyWith(
            fontSize: 12,
            color: const Color(0xFFB6B7B7),
          ),
        ),
      ],
    );
  }
}
