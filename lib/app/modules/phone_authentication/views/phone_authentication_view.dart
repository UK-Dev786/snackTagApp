import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';
import 'package:snacktag/widgets/custom_textfeild.dart';
import 'package:snacktag/widgets/reuse_button.dart';
import '../../../../config/app_images.dart';
import '../controllers/phone_authentication_controller.dart';

class PhoneAuthenticationView extends GetView<PhoneAuthenticationController> {
  const PhoneAuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Builder(builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 200),

                Image.asset(
                  AppImages.authImg,
                  width: 85,
                  height: 95,
                ),

                const SizedBox(height: 50),

                // Heading
                Text(
                  'PHONE AUTHENTICATION',
                  style: AppTextStyles.MetropolisMedium.copyWith(
                    fontSize: 18,
                    color: const Color(0xFF434343),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Please Enter Your Phone Number',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.MetropolisRegular.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF858585),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone number field
                Container(
                  height: 56,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Mobile No',
                        labelStyle: AppTextStyles.MetropolisRegular.copyWith(
                          color: const Color(0xFFB6B7B7),
                          fontSize: 12,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: InputBorder.none,
                        counterText: '',
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      initialCountryCode: 'PK',
                      onChanged: (phone) {
                        controller.phoneController.text = phone.completeNumber;
                      },
                      autovalidateMode: AutovalidateMode.disabled),
                ),

                const SizedBox(height: 30),

                // Continue button
                Obx(
                  () => CustomButton1(
                    text: 'CONTINUE',
                    onPressed: () async =>
                        await controller.authenticatePhoneNumber(),
                    isLoading: controller.isLoading.value,
                    //  gradientColors: const [Colors.orange, Colors.red],
                    height: 60.0,
                    borderRadius: 12.0,
                    fontSize: 18.0,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }
}
