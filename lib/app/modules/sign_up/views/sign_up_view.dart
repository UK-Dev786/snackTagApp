import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  final bool isCafeteria;
  const SignUpView({super.key, this.isCafeteria = true});

  @override
  Widget build(BuildContext context) {
    // Define controllers for text fields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();

    RxBool confirm = false.obs;

    return WillPopScope(
      onWillPop: () async => false, // Prevent the user from going back
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Equal left and right padding
            child: Column(
              children: [
                // Padding to push the content down by 100 from the top
                const SizedBox(height: 60),

                // Circular logo with an icon (where the user can upload an image)
                GestureDetector(
                  onTap: () {
                    // Handle image upload action here (e.g., open gallery)
                  },
                  child: Container(
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      color: isCafeteria ? Colors.white : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 3, // Border width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Center(
                      child: isCafeteria
                          ? Text('LOGO',
                              style: AppTextStyles.PoppinsMedium.copyWith(
                                  fontSize: 18, color: const Color(0xFF434343)))
                          : Image.asset(
                              'assets/images/icecream.png', // Replace with your image path

                              fit: BoxFit
                                  .contain, // Ensures the image fits inside
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 40), // Space between logo and form

                // Row for "SIGN UP" and "ALREADY A USER? LOGIN NOW"
                // Row for "LOGIN" and "NEW USER? SIGN UP NOW"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SIGNUP',
                      style: AppTextStyles.MetropolisMedium.copyWith(
                          fontSize: 18,
                          color: const Color(
                              0xFF434343)), // Custom text style for heading
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the sign-up screen
                        Get.toNamed(Routes.SIGN_UP);
                      },
                      child: Text(
                        'YOU HAVE AN ACC! LOGIN NOW',
                        style: AppTextStyles.MetropolisRegular.copyWith(
                            fontSize: 13, color: const Color(0xFF858585)),
                      ),
                    ),
                  ],
                ),

                if (!isCafeteria)
                  const SizedBox(
                      height: 10), // Space between Row and TextFields

                // Name TextField widget
                if (!isCafeteria)
                  TextFieldWidget(
                    text: 'Name',
                    path: 'assets/icon/user.png',
                    keyboardType: TextInputType.name,
                    textController: nameController,
                  ),

                if (isCafeteria)
                  const SizedBox(
                      height: 10), // Space between Row and TextFields

                // Name TextField widget
                if (isCafeteria)
                  TextFieldWidget(
                    text: 'Cafertia Name',
                    path: 'assets/icon/cafe.png',
                    keyboardType: TextInputType.name,
                    textController: nameController,
                  ),
                if (isCafeteria)
                  const SizedBox(
                      height: 10), // Space between Row and TextFields

                // Name TextField widget
                if (isCafeteria)
                  TextFieldWidget(
                    text: 'School/Collage Name',
                    path: 'assets/icon/school.png',
                    keyboardType: TextInputType.name,
                    textController: nameController,
                  ),
                const SizedBox(height: 10), // Space between Row and TextFields

                // Name TextField widget
                if (isCafeteria)
                  TextFieldWidget(
                    text: 'Location',
                    path: 'assets/icon/location.png',
                    keyboardType: TextInputType.name,
                    textController: nameController,
                  ),

                if (isCafeteria)
                  const SizedBox(
                      height: 10), // Space between Row and TextFields

                TextFieldWidget(
                  text: 'Email',
                  path: 'assets/icon/email.png',
                  keyboardType: TextInputType.emailAddress,
                  textController: emailController,
                ),

                const SizedBox(
                    height: 10), // Space between email and phone fields

                // Phone Number TextField widget
                TextFieldWidget(
                  text: 'Mobile No',
                  path: 'assets/icon/call_light.png',
                  keyboardType: TextInputType.phone,
                  textController: phoneController,
                ),

                const SizedBox(
                    height: 10), // Space between phone and address fields

                // Address TextField widget
                TextFieldWidget(
                  text: 'Password',
                  path: 'assets/icon/unlock.png',
                  keyboardType: TextInputType.streetAddress,
                  textController: addressController,
                  isPassword: true,
                ),

                const SizedBox(
                    height: 10), // Space between address and city fields

                // City TextField widget
                TextFieldWidget(
                  text: 'Confirm Password',
                  path: 'assets/icon/unlock.png',
                  keyboardType: TextInputType.text,
                  textController: cityController,
                  isPassword: true,
                ),

                const SizedBox(
                    height:
                        20), // Space between password fields and sign-up button

                // Custom Sign-Up Button
                CustomButton(
                  text: 'SIGNUP',
                  onPressed: () {
                    // Handle sign-up action here
                    // Validate if passwords match and perform sign-up logic
                    if (passwordController.text ==
                        confirmPasswordController.text) {
                      // Proceed with sign-up logic
                    } else {
                      // Show error message for password mismatch
                      Get.snackbar("Error", "Passwords do not match");
                    }
                  },
                  isLoading: false.obs, // RxBool for loading state
                 // gradientColors: const [Colors.orange, Colors.red],
                  height: 60.0,
                  borderRadius: 12.0,
                  fontSize: 18.0,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                ),

                const SizedBox(
                    height: 15), // Space between sign-up button and terms

                // Terms and conditions (optional)

                Row(
                  children: [
                    // RoundCheckBox widget (for terms and conditions)
                    RoundCheckBox(
                      size: 20, // Size of the checkbox
                      border: Border.all(
                        color: confirm.value
                            ? Colors.green
                            : Colors.grey, // Dynamic border color
                      ),
                      isChecked: confirm.value, // Checkbox state
                      checkedWidget: const Icon(
                        Icons.check_rounded,
                        size:
                            12, // Adjust the size of the tick mark to fit inside the checkbox
                        color: AppColors.whiteColor, // Tick mark color
                      ),
                      onTap: (tapped) => confirm.value =
                          !confirm.value, // Toggle the checkbox state
                    ),

                    SizedBox(width: 10), // Space between checkbox and text
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          // Handle terms and conditions action here
                        },
                        child: Text(
                          'Accept Terms & Conditions',
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              fontSize: 15, color: const Color(0xFF707070)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
