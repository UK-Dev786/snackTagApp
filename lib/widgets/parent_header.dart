import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_images.dart';
import 'package:snacktag/config/app_text_style.dart';
import '../app/modules/parents_add_wallet/controllers/parents_add_wallet_controller.dart';
import '../app/routes/app_pages.dart';
import '../config/app_colors.dart';
import '../app/modules/parents_home/controllers/parents_home_controller.dart';

class ParentsHeader extends StatelessWidget {
  const ParentsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final parentController = Get.find<ParentsHomeController>();

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView to prevent overflow
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.baseBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum vertical space
            children: [
              const SizedBox(height: 50), // Reduced top spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100, // or a fixed width if needed
                        height: 45, // adjust height as needed
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.headerBtn),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Text(
                          'BALANCE',
                          // style: TextStyle(
                          //   color: Colors.black.withOpacity(0.7),
                          //   fontSize: 8,
                          //   fontWeight: FontWeight.bold,
                          // ),
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 7,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 10,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'MX\$ ',
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${parentController.parentAddWalletModel.value?.amount ?? "0.00"}',
                                style: AppTextStyles.MetropolisRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showAddWalletDialog(context, parentController);
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 100, // or a fixed width if needed
                          height: 45, // adjust height as needed
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AppImages.headerBtn),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Text(
                            'WALLET',
                            style: AppTextStyles.MetropolisRegular.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 7,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 10,
                          child: Text(
                            'ADD',
                            style: AppTextStyles.MetropolisRegular.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 100, // or a fixed width if needed
                        height: 45, // adjust height as needed
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.headerBtn),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 15,
                        child: Image.asset(
                          AppImages.shopped,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 10,
                        child: Text(
                          'MX\$ ',
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 8,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 15),
              // Parent image with circular container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0), // 5px padding
                  child: ClipOval(
                    child: Obx(
                      () => parentController.parentProfileImage.value != null &&
                              parentController
                                  .parentProfileImage.value!.isNotEmpty
                          ? Image.network(
                              parentController.parentProfileImage.value!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppImages.profile,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              AppImages.profile,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                  parentController.parentName.value ?? 'Parent Name ✏️',
                  style: AppTextStyles.MetropolisRegular.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor))),
              // Child images horizontal list
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 80, // Reduced height
                  child: Obx(
                    () => parentController.childrenList.isEmpty
                        ? Center(
                            child: Text(
                              'No children added yet',
                              style: AppTextStyles.MetropolisRegular.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: parentController.childrenList.length,
                            itemBuilder: (context, index) {
                              final child =
                                  parentController.childrenList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: SizedBox(
                                  width: 55, // Reduced width
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min, // Use minimum space
                                    children: [
                                      Container(
                                        width: 55, // Reduced size
                                        height: 55, // Reduced size
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              3.0), // 5px padding
                                          child: ClipOval(
                                            child:
                                                child.childImageUrl != null &&
                                                        child.childImageUrl!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                        child.childImageUrl!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Image.asset(
                                                            AppImages.profile,
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      )
                                                    : Image.asset(
                                                        AppImages.profile,
                                                        fit: BoxFit.cover,
                                                      ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Text with constrained height and overflow handling
                                      Text(
                                        child.childName ?? 'Child',
                                        style: AppTextStyles.MetropolisRegular
                                            .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 8,
                                          color: AppColors.blackColor,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWalletDialog(
      BuildContext context, ParentsHomeController controller) {
    final TextEditingController amountController = TextEditingController();
    int selectedAmount = -1;
    final List<double> presetAmounts = [100.00, 500.00, 800.00, 1000.00];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button at top right
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          AppImages.crossIcon,
                          width: 29,
                          height: 29,
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      'WALLET',
                      style: AppTextStyles.MetropolisBold.copyWith(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Preset amounts in a grid (2x2)
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < presetAmounts.length; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAmount = i;
                                amountController.text =
                                    presetAmounts[i].toStringAsFixed(2);
                              });
                            },
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: selectedAmount == i
                                      ? AppColors.gradientStartColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'MX\$${presetAmounts[i].toStringAsFixed(2)}',
                                style: AppTextStyles.MetropolisMedium.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Custom amount input
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'MX\$0.00',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.MetropolisRegular.copyWith(
                            color: Colors.grey,
                          ),
                          prefixText: selectedAmount == -1 ? 'MX\$' : '',
                          prefixStyle: AppTextStyles.MetropolisRegular.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 16,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              selectedAmount = -1;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Done button
                    GestureDetector(
                      onTap: () {
                        if (amountController.text.isNotEmpty) {
                          // Navigate to add wallet page with the amount
                          Navigator.of(context).pop();

                          // Create a temporary controller to pass the amount
                          final tempController =
                              Get.find<ParentsAddWalletController>();
                          tempController.amount.value =
                              amountController.text.replaceAll('\$', '');

                          // Navigate to add wallet page
                          Get.toNamed(Routes.PARENTS_ADD_WALLET);
                        } else {
                          // Show error if no amount is entered
                          Get.snackbar(
                            'Error',
                            'Please enter an amount',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFD6FF00), // Bright yellow-green color
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'DONE',
                          style: AppTextStyles.MetropolisBold.copyWith(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
