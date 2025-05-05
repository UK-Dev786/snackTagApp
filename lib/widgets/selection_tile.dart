import 'package:flutter/material.dart';
import 'package:snacktag/config/app_colors.dart';
import 'package:snacktag/config/app_text_style.dart';

class SelectionTile extends StatelessWidget {
  final String imgPath;
  final double imageHeight;
  final double imageWidth;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionTile({
    required this.imgPath,
    this.imageHeight = 102,
    this.imageWidth = 102,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 182,
        width: 136,
        // decoration: BoxDecoration(
        //   // color: Colors.grey[200],
        //   // borderRadius: const BorderRadius.all(Radius.circular(15)),
        //   border: isSelected
        //       ? Border.all(
        //           color: AppColors.gradientStartColor, // Highlight color
        //           width: 3.0,
        //         )
        //       : null,
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.2),
        //       blurRadius: 6,
        //       offset: const Offset(0, 3),
        //     ),
        //   ],
        // ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imgPath,
              height: imageHeight,
              width: imageWidth,
              fit: BoxFit.contain,
            ),
            // Positioned(
            //   bottom: 10,
            //   child: Text(
            //     text,
            //     style: AppTextStyles.MetropolisBold.copyWith(
            //       fontSize: 22,
            //       color: const Color(0xFF1B1C20),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
