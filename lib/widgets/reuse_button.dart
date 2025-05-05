import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsets padding;
  final double fontSize;

  final RxBool isLoading; // Changed to RxBool
  final bool isBackColor; // New parameter to control background color
  final double width;
  final Color forcedTextColor;
  final bool isForcedTextColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0,
    this.isForcedTextColor = false,
    this.forcedTextColor = AppColors.blackColor,
    this.width = double.infinity,
    this.gradientColors = const [
      AppColors.gradientStartColor,
      AppColors.gradientEndColor,
    ],
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.fontSize = 16.0,
    required this.isLoading, // Made required since we need the RxBool instance
    this.isBackColor = true, // Default value for isBackColor is true
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading.value
          ? null
          : onPressed, // Use .value to access RxBool
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // Check if isBackColor is true, then apply gradient
            gradient: isBackColor
                ? LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.bottomLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isBackColor
                ? null
                : AppColors.whiteColor, // Apply solid background if no gradient
            borderRadius: BorderRadius.circular(50),
            boxShadow: isBackColor || isForcedTextColor
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 2,
                    )
                  ]
                : null, // No shadow when no background color
          ),
          child: Material(
            color: Colors.transparent,
            child:
                Center(
                  child: isLoading.value == true // Use .value to access RxBool
                      ? SizedBox(
                          height: height * 0.5,
                          width: height * 0.5,
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : Text(text,
                          style: isBackColor
                              ? AppTextStyles.MetropolisBold.copyWith(
                                  fontSize: fontSize,
                                  color: AppColors.whiteColor,
                                )
                              : isForcedTextColor
                                  ? AppTextStyles.PoppinsRegular.copyWith(
                                      fontSize: fontSize,
                                      color: forcedTextColor,
                                    )
                                  : AppTextStyles.PoppinsBold.copyWith(
                                      fontSize: fontSize,
                                      color: const Color(0xFFFF2F69),
                                    )),
                )),

        ),
      ),
    );
  }
}

// this is my code
class CustomButton1 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsets padding;
  final double fontSize;

  final bool isLoading; // Changed to RxBool
  final bool isBackColor; // New parameter to control background color
  final double width;
  final Color forcedTextColor;
  final bool isForcedTextColor;

  const CustomButton1( {
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0,
    this.isForcedTextColor = false,
    this.forcedTextColor = AppColors.blackColor,
    this.width = double.infinity,
    this.gradientColors = const [
      AppColors.gradientStartColor,
      AppColors.gradientEndColor,
    ],
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.fontSize = 16.0,
    required this.isLoading, // Made required since we need the RxBool instance
    this.isBackColor = true, // Default value for isBackColor is true
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : onPressed, // Use .value to access RxBool
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // Check if isBackColor is true, then apply gradient
            gradient: isBackColor
                ? LinearGradient(
              colors: gradientColors,
              begin: Alignment.bottomLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isBackColor
                ? null
                : AppColors.whiteColor, // Apply solid background if no gradient
            borderRadius: BorderRadius.circular(50),
            boxShadow: isBackColor || isForcedTextColor
                ? [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 2,
              )
            ]
                : null, // No shadow when no background color
          ),
          child: Material(
              color: Colors.transparent,
              child:
              Center(
                child: isLoading == true // Use .value to access RxBool
                    ? SizedBox(
                  height: height * 0.5,
                  width: height * 0.5,
                  child: const CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                )
                    : Text(text,
                    style: isBackColor
                        ? AppTextStyles.MetropolisBold.copyWith(
                      fontSize: fontSize,
                      color: AppColors.whiteColor,
                    )
                        : isForcedTextColor
                        ? AppTextStyles.PoppinsRegular.copyWith(
                      fontSize: fontSize,
                      color: forcedTextColor,
                    )
                        : AppTextStyles.PoppinsBold.copyWith(
                      fontSize: fontSize,
                      color: const Color(0xFFFF2F69),
                    )),
              )),

        ),
      ),
    );
  }
}
