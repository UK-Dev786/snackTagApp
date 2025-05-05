import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

import '../controllers/parents_add_wallet_controller.dart';

class ParentsAddWalletView extends GetView<ParentsAddWalletController> {
  const ParentsAddWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Add Amount To Wallet',
                      style: AppTextStyles.MetropolisBold.copyWith(
                        color: const Color(0xFF434343),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Amount TextField
                  Obx(
                    () => SimpleTextFieldWithOutSuffixWidget(
                      hintText: 'Type Amount',
                      keyboardType: TextInputType.number,
                      controller: TextEditingController()
                        ..text = controller.amount.value
                        ..selection =
                            TextSelection.collapsed(offset: controller.amount.value.length),
                      onChanged: controller.clearSelectionOnTyping,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Peso Selector
                  Obx(
                    () => buildPesoSelector(
                      selectedIndex: controller.selectedIndex.value,
                      onSelect: (index, amount) => controller.selectPeso(index, amount),
                    ),
                  ),

                  // Checkbox
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => controller.isMonthlyReloadEnabled.toggle(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Enable Monthly Reload?',
                                style: AppTextStyles.MetropolisMedium.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              Obx(
                                () => Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => controller.isMonthlyReloadEnabled.toggle(),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      width: 30, // Increased tap area
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: controller.isMonthlyReloadEnabled.value
                                          ? const Icon(
                                              Icons.check,
                                              size: 18,
                                              color: Colors.black,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // Add Button
            Obx(
              () => CustomButton1(
                text: 'Add',
                onPressed: () {

                  print("Monthly Reload Enabled: ${controller.isMonthlyReloadEnabled.value}");
                  print("Amount Entered: ${controller.amount.value}");
                  controller.saveWalletData();
                },
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPesoSelector({
    required int selectedIndex,
    required Function(int, int) onSelect,
  }) {
    final List<int> pesos = [100, 200, 500, 1000];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: pesos.asMap().entries.map((entry) {
          final index = entry.key;
          final amount = entry.value;

          return GestureDetector(
            onTap: () => onSelect(index, amount),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: selectedIndex == index ? null : Colors.white,
                borderRadius: BorderRadius.circular(30),
                gradient: selectedIndex == index
                    ? const LinearGradient(
                        colors: [AppColors.gradientStartColor, AppColors.gradientEndColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
              ),
              child: Text(
                '$amount peso',
                style: AppTextStyles.MetropolisRegular.copyWith(
                  color: selectedIndex == index ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
