import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/cafeteria_add_staff/controllers/cafeteria_add_staff_controller.dart';
import 'package:snacktag/app/modules/cafeteria_add_staff/views/cafeteria_add_staff_view.dart';
import 'package:snacktag/app/modules/cafeteria_home_settings/controllers/cafeteria_home_settings_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/reuse_button.dart';

class CafeteriaStaffListView extends StatelessWidget {
  const CafeteriaStaffListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CafeteriaHomeSettingsController>();
    final List<String> staffMembers = [
      'Sandra Vargas',
      'Matthew Murphy',
      'Emma',
      'Sara Mendez',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: GetBuilder<CafeteriaAddStaffController>(
            init: CafeteriaAddStaffController(),
            builder: (addStaffController) {
              return Obx(
                () =>
                addStaffController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    :
                Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      // controller.updateSelectedIndex(0);
                                      Get.back();
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      margin: const EdgeInsets.only(top: 16),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 4,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/icon/back.png",
                                          height: 15,
                                          width: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Staff Members',
                                    style: AppTextStyles.MetropolisBold.copyWith(
                                      color: const Color(0xFF434343),
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: addStaffController.staffDataList.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                  width: 39,
                                                  height: 39,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border:
                                                        Border.all(color: Colors.white, width: 3),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.3),
                                                        spreadRadius: 2,
                                                        blurRadius: 6,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: CircleAvatar(
                                                      radius: 35,

                                                      // backgroundImage: AssetImage(
                                                      //     'assets/images/icecream.png'),
                                                      child: addStaffController
                                                                  .staffDataList[index].imageUrl !=
                                                              null
                                                          ? ClipOval(
                                                            child: Image.network(
                                                                addStaffController
                                                                    .staffDataList[index].imageUrl!,
                                                                width: double.infinity,
                                                                // height: 100,
                                                                fit: BoxFit.cover,
                                                                // errorBuilder: (context, error, stackTrace) {
                                                                //   return Image.asset(
                                                                //     'assets/images/icecream.png',
                                                                //     width: double.infinity,
                                                                //     fit: BoxFit.cover,
                                                                //   );
                                                                // },
                                                              ),
                                                          )
                                                          : Image.asset(
                                                              'assets/images/profile_emoji.png',
                                                              width: double.infinity,
                                                              fit: BoxFit.cover,
                                                            ))),
                                              const SizedBox(width: 16),
                                              Text(
                                                addStaffController.staffDataList[index].staffName!,
                                                style: AppTextStyles.MetropolisMedium.copyWith(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // Edit action here
                                                  // controller.updateSelectedIndex(4);
                                                  Get.toNamed(Routes.CAFETERIA_Edit_STAFF,
                                                      arguments: {
                                                        'staffModelL':
                                                            addStaffController.staffDataList[index],
                                                      });
                                                },
                                                child: Text(
                                                  'Edit',
                                                  style: AppTextStyles.MetropolisRegular.copyWith(
                                                    fontSize: 12,
                                                    color: const Color(0xFFFF9A0D),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              GestureDetector(
                                                onTap: () {
                                                  // Delete action here
                                                  if (addStaffController.staffDataList[index].id !=
                                                      null) {
                                                    addStaffController.deleteStaffData(
                                                        addStaffController
                                                            .staffDataList[index].id!);
                                                  }
                                                },
                                                child: Image.asset(
                                                  'assets/icon/delete.png',
                                                  width: 15,
                                                  height: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          CustomButton(
                            text: 'Add',
                            onPressed: () {
                              Get.toNamed(Routes.CAFETERIA_ADD_STAFF);
                              // Add button action here
                            },
                            isLoading: false.obs,
                          ),
                        ],
                      ),
              );
            }),
      ),
    );
  }
}
