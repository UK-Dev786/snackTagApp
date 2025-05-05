import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/parent_children_edit/controller/parent_children_edit_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_back_button.dart';
import 'package:snacktag/widgets/custom_dialog.dart';
import 'package:snacktag/widgets/custom_snackbar.dart';
import 'package:snacktag/widgets/custom_textfield_without_suffix.dart';
import 'package:snacktag/widgets/reuse_button.dart';

bool isEdit = false;

class ParentsChildrenEditView extends GetView<ParentsChildrenEditController> {
  const ParentsChildrenEditView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Obx(() {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 90),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'CHILDREN DETAILS',
                        style: AppTextStyles.MetropolisMedium.copyWith(
                          color: const Color(0xFF434343),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Column(
                      children: [
                        _buildCenterImage(), // Center Image
                        const SizedBox(height: 30),
                        _buildTextFields(context),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton1(
                fontSize: 16,
                isBackColor: true,
                text: 'CONTINUE',
                onPressed: () {
                  if (controller.nameControllers.value.text.isEmpty ||
                      controller.idControllers.value.text.isEmpty ||
                      controller.schoolNameController.text.isEmpty) {
                    showCustomSnack(
                        "Please Enter a School Name, Child Name and School ID");
                    return;
                  }
                  print(
                      "Selected School Name for Child : ${controller.nameControllers.text}");
                  print(
                      "Selected School id for Child : ${controller.idControllers.text}");

                  // Get.toNamed(
                  //   Routes.CAFETERIA,
                  //   arguments: {
                  //     "schoolName": controller.schoolNameController.text,
                  //     "isEdit": true,
                  //   },
                  // );
                  isEdit = true;
                  Get.toNamed(Routes.CAFETERIA,
                      arguments: controller.schoolNameController.text);
                },
                isLoading: controller.isLoading.value,
              ),
              const SizedBox(height: 32),
            ],
          );
          // }
        }),
      ),
    );
  }

  // Center circular image
  Widget _buildCenterImage() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Obx(
            () => Container(
              width: 102,
              height: 102,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3, // Border with a width of 3
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1), // Shadow color with opacity
                    blurRadius: 5, // Blur effect
                    spreadRadius: 2, // Spread radius
                    offset: const Offset(0, 1), // Position of the shadow (x, y)
                  ),
                ],
              ),
              child: ClipOval(
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error_outline_outlined,
                                  size: 20); //_buildPlaceholder();
//_buildPlaceholder();
                            },
                          )
                        : Image.asset(
                            // 'assets/images/userimg.png', // Replace with the actual image URL
                            'assets/images/profile_emoji.png', // Replace with the actual image URL
                            fit: BoxFit.cover,
                          ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: CustomBackButton(
                  onTap: () => controller.pickImage(),
                  widget: const Icon(
                    Icons.edit,
                    size: 18,
                  )))
        ],
      ),
    );
  }

  // Reusable text fields
// Modify the _buildTextFields() method in ParentsChildrenDetailsView
  Widget _buildTextFields(BuildContext context) {
    return Column(
      children: [
        SimpleTextFieldWithOutSuffixWidget(
          hintText: 'Child Name',
          controller: controller.nameControllers,
        ),
        const SizedBox(height: 12),
        SimpleTextFieldWithOutSuffixWidget(
          hintText: 'Child School ID',
          controller: controller.idControllers,
        ),
        const SizedBox(height: 12),
        SimpleTextFieldWithOutSuffixWidget(
          hintText: 'School/Collage Name',
          isReadOnly: true,
          controller: controller
              .schoolNameController, // Add this controller to your main controller
          onTap: () async {
            // controller.fetchSchoolNames();
            print("Fetched School Names: ${controller.schoolNamesList}");

            final selectedSchool = await SchoolSelectorDialog.show(
                context, controller.schoolNamesList,
                isEdit: true);
            controller.schoolNameController.text = selectedSchool!;
            print("Selected School Names: $selectedSchool");
          },
        ),
      ],
    );
  }
}
