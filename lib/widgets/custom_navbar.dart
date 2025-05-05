import 'package:flutter/material.dart';
import 'package:snacktag/config/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<String> imagePaths;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 50,
      padding: EdgeInsets.zero,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(imagePaths.length, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  debugPrint("Tapped on index: $index");
                  onItemTapped(index);
                },
                behavior: HitTestBehavior.opaque, // Ensures the entire area is tappable
                child: SizedBox(
                  height: 50, // Ensure a tappable height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Gradient Indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        width: selectedIndex == index ? 43 : 0,
                        decoration: BoxDecoration(
                          gradient: selectedIndex == index
                              ? const LinearGradient(
                            colors: [  AppColors.gradientStartColor,
                              AppColors.gradientEndColor,],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Icon
                      SizedBox(
                        height: 26,
                        child: Center(
                          child: Image.asset(
                            imagePaths[index],
                            width: imagePaths[index] == 'assets/icon/idcard.png' ? 26 :
                            (imagePaths[index] == 'assets/icon/active.png' ? 23 : 20),
                            height: imagePaths[index] == 'assets/icon/idcard.png' ? 26 :
                            (imagePaths[index] == 'assets/icon/active.png' ? 23 : 20),
                            color: const Color(0xFF707070),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            return Expanded(
              child: GestureDetector(
                onTap: () => onItemTapped(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Gradient Indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: selectedIndex == index ? 43 : 0,
                      decoration: BoxDecoration(
                        gradient: selectedIndex == index
                            ? const LinearGradient(
                                colors: [Colors.pink, Colors.orange],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Container to maintain consistent alignment
                    SizedBox(
                      height: 26, // Height of the largest icon
                      child: Center(
                        // Centers the image vertically
                        child: Image.asset(
                          imagePaths[index],
                          width: imagePaths[index] == 'assets/icon/idcard.png'
                              ? 26
                              : (imagePaths[index] == 'assets/icon/active.png'
                                  ? 23
                                  : 20),
                          height: imagePaths[index] == 'assets/icon/idcard.png'
                              ? 26
                              : (imagePaths[index] == 'assets/icon/active.png'
                                  ? 23
                                  : 20),
                          color: const Color(0xFF707070),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
