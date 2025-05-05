import 'package:flutter/material.dart';
import 'package:snacktag/config/app_text_style.dart';

class CustomAppBarCaferteria extends StatelessWidget
    implements PreferredSizeWidget {
  final String userName;
  final String userLocation;
  final String? userImage;
  final String? optionalText;

  const CustomAppBarCaferteria({
    Key? key,
    required this.userName,
    required this.userLocation,
    this.userImage,
    this.optionalText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Adjust height to fit content
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/header.png', // Replace with your background image asset
              fit: BoxFit.fill,
              color: Color(0xFFF8FAFC),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 20), // Adjust height to fit content
                Row(
                  children: [
                    // User Image
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300], // Placeholder background
                        image: userImage != null
                            ? DecorationImage(
                                image: AssetImage(userImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: userImage == null
                          ? Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // User Name and Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              color: Colors.black, fontSize: 14),
                        ),
                        Text(
                          userLocation,
                          style: AppTextStyles.MetropolisRegular.copyWith(
                              color: Color(0xFF858585), fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                if (optionalText != null) ...[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      optionalText!,
                      style: AppTextStyles.MetropolisMedium.copyWith(
                          color: Color(0xFF434343), fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 0), // Adjust height to fit content
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(170);
}

class SimpleCustomAppBarCafeteria extends StatelessWidget
    implements PreferredSizeWidget {
  final String optionalText;

  const SimpleCustomAppBarCafeteria({
    Key? key,
    required this.optionalText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170, // Fixed height
      child: Stack(
        children: [
          // Background Image

          Positioned.fill(
            child: Image.asset(
              'assets/images/header.png', // Replace with your background image asset
              fit: BoxFit.fill,

              color: Color(0xFFF8FAFC),
            ),
          ),
          // Centered Optional Text

          Padding(
            padding: const EdgeInsets.only(bottom: 52),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                optionalText,
                style: AppTextStyles.MetropolisMedium.copyWith(
                    color: Color(0xFF434343), fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(170);
}
