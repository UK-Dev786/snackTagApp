import 'package:flutter/material.dart';
import 'package:snacktag/config/app_text_style.dart';

class CafeteriaSettingWidget extends StatelessWidget {
  final String labelName;
  final Function()? onTap;
  const CafeteriaSettingWidget({super.key,required this.labelName,required this.onTap});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Orange Circular Dot
                Image.asset(
                  'assets/icon/dot.png',
                  width: 10,
                  height: 10,
                ),
                const SizedBox(
                    width: 16), // Spacing between dot and text
                // Title
                Expanded(
                  child: Text(
                    labelName,
                    style:
                    AppTextStyles.MetropolisRegular.copyWith(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Trailing Arrow
                Image.asset(
                  'assets/icon/arrow.png',
                  width: 24,
                  height: 17,
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFFEEEEEE),
            thickness: 1,
          )
        ],
      ),
    );
  }
}
