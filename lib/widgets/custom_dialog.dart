import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/modules/parents_children_details/controllers/parents_children_details_controller.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';

class SchoolSelectorDialog extends StatefulWidget {
  final List<String> schoolsList;
  final bool isEdit;

  const SchoolSelectorDialog(
      {super.key, required this.schoolsList, this.isEdit = false});

  static Future<String?> show(BuildContext context, List<String> schoolsList,
      {bool isEdit = false}) async {
    return await showDialog<String>(
      context: context,
      builder: (
        BuildContext context,
      ) =>
          SchoolSelectorDialog(
        schoolsList: schoolsList,
        isEdit: isEdit,
      ),
    );
  }

  @override
  State<SchoolSelectorDialog> createState() => _SchoolSelectorDialogState();
}

class _SchoolSelectorDialogState extends State<SchoolSelectorDialog> {
  final ParentsChildrenDetailsController controller =
      Get.find<ParentsChildrenDetailsController>();
  final TextEditingController textController = TextEditingController();
  // final List<String> schools = [
  //   'Cambridge International School',
  //   'St. Patrick\'s High School',
  //   'The American International Academy'
  // ];
  List<String> filteredSchools = [];

  @override
  void initState() {
    super.initState();
    print(
        "Fetched School Names Dialog box: ${controller.schoolNamesList.length} schools: ${controller.schoolNamesList}");

    // If the controller's list is empty, use the widget's list (which might have been populated with defaults)
    if (controller.schoolNamesList.isNotEmpty) {
      filteredSchools = List.from(controller.schoolNamesList);
      print(
          "Using controller's school list (${filteredSchools.length}): $filteredSchools");
    } else if (widget.schoolsList.isNotEmpty) {
      filteredSchools = List.from(widget.schoolsList);
      print(
          "Using widget's school list (${filteredSchools.length}): $filteredSchools");
    } else {
      // If both lists are empty, add a default school
      filteredSchools = ["Test School"];
      print("Using default school list: $filteredSchools");
    }

    // Force the controller to fetch schools if the list is empty
    if (controller.schoolNamesList.isEmpty) {
      controller.fetchSchoolNames().then((_) {
        setState(() {
          if (controller.schoolNamesList.isNotEmpty) {
            filteredSchools = List.from(controller.schoolNamesList);
            print(
                "Updated with freshly fetched schools (${filteredSchools.length}): $filteredSchools");
          }
        });
      });
    }

    textController.addListener(() {
      filterSchools();
    });
  }

  void filterSchools() {
    setState(() {
      // Always use the most up-to-date list of schools
      List<String> sourceList;

      // Prefer controller's list if it has schools
      if (controller.schoolNamesList.isNotEmpty) {
        sourceList = List.from(controller.schoolNamesList);
        print(
            "Filtering using controller's list (${sourceList.length}): $sourceList");
      }
      // Fall back to widget's list if controller has no schools
      else if (widget.schoolsList.isNotEmpty) {
        sourceList = List.from(widget.schoolsList);
        print(
            "Filtering using widget's list (${sourceList.length}): $sourceList");
      }
      // Use default if both are empty
      else {
        sourceList = ["Test School"];
        print("Filtering using default list: $sourceList");
      }

      // Apply text filter if search text is not empty
      if (textController.text.isEmpty) {
        filteredSchools = sourceList;
      } else {
        String searchText = textController.text.toLowerCase();
        filteredSchools = sourceList
            .where((school) => school.toLowerCase().contains(searchText))
            .toList();

        print(
            "Filtered to ${filteredSchools.length} schools matching '$searchText'");
      }

      // If no schools match the filter and we're not searching, show all schools
      if (filteredSchools.isEmpty && textController.text.isEmpty) {
        // This should never happen since we're using the source list directly
        // But just in case, add a default school
        filteredSchools = ["Test School"];
        print("No schools found after filtering, using default");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.gradientStartColor,
              AppColors.gradientEndColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFieldWidget(
              text: 'Search',
              textController: textController,
              path: 'assets/icon/search.png',
              isBGChangeColor: true,
              height: 40,
              isSuffixBG: true,
              onChanged: (value) => filterSchools(),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: filteredSchools.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Results Found',
                          style: AppTextStyles.MetropolisMedium.copyWith(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Please try again with a different keyword',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.MetropolisRegular.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filteredSchools.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: widget.isEdit == true
                              ? () {
                                  Get.back(result: filteredSchools[index]);
                                }
                              : controller.allChildrenSameSchool.value == "Yes"
                                  ? () {
                                      controller.schoolNameController.text =
                                          filteredSchools[index];
                                      print(
                                          "Selected School gg Names: ${filteredSchools[index]}");

                                      Get.back();
                                    }
                                  : () {
                                      print(
                                          "Selected School gg Names: ${filteredSchools[index]}");
                                      controller.schoolNameController.text =
                                          filteredSchools[index];
                                      Get.back(result: filteredSchools[index]);
                                      Get.toNamed(Routes.CAFETERIA,
                                          arguments: filteredSchools[index]);
                                    },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              filteredSchools[index],
                              style: AppTextStyles.MetropolisMedium.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
