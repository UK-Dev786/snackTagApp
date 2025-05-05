// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:snacktag/config/app_fonts.dart';

class AppTextStyles {
  // Metropolis Regular (18pt, weight: w400)
  static const TextStyle MetropolisRegular = TextStyle(
    fontSize: 18,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w400, // Regular
  );

  // Metropolis Medium (18pt, weight: w500)
  static TextStyle MetropolisMedium = const TextStyle(
    fontSize: 18,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w500, // Medium
  );

  // Metropolis Bold (20pt, weight: w700)
  static TextStyle MetropolisBold = const TextStyle(
    fontSize: 20,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w700, // Bold
  );

  // Metropolis ExtraBold (22pt, weight: w800)
  static TextStyle MetropolisExtraBold = const TextStyle(
    fontSize: 22,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w800, // ExtraBold
  );

  // Metropolis Light (16pt, weight: w300)
  static TextStyle MetropolisLight = const TextStyle(
    fontSize: 16,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w300, // Light
  );

  // Metropolis SemiBold (19pt, weight: w600)
  static TextStyle MetropolisSemiBold = const TextStyle(
    fontSize: 19,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w600, // SemiBold
  );

  // Metropolis Thin (14pt, weight: w100)
  static TextStyle MetropolisThin = const TextStyle(
    fontSize: 14,
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w100, // Thin
  );

  // Metropolis Regular Italic (16pt, weight: w400, style: italic)
  static TextStyle MetropolisRegularItalic = const TextStyle(
    fontSize: 45, // Set your desired font size
    fontFamily:
        AppFonts.METROPOLIS, // Use the METROPOLIS font from the AppFonts class
    fontWeight: FontWeight.w400, // Regular weight
    fontStyle: FontStyle.italic, // Italic style
  );

  // Altoys Italic
  static TextStyle AltoysItalic = const TextStyle(
    fontSize: 16, // Set the default font size
    fontFamily: 'Altoys', // Use the Altoys font family
    fontStyle: FontStyle.italic, // Set the style to italic
  );

  // Poppins Regular (18pt, weight: w400)
  static const TextStyle PoppinsRegular = TextStyle(
    fontSize: 18,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w400, // Regular
  );

  // Poppins Medium (18pt, weight: w500)
  static TextStyle PoppinsMedium = const TextStyle(
    fontSize: 18,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w500, // Medium
  );

  // Poppins Bold (20pt, weight: w700)
  static TextStyle PoppinsBold = const TextStyle(
    fontSize: 20,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w700, // Bold
  );

  // Poppins ExtraBold (22pt, weight: w800)
  static TextStyle PoppinsExtraBold = const TextStyle(
    fontSize: 22,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w800, // ExtraBold
  );

  // Poppins Light (16pt, weight: w300)
  static TextStyle PoppinsLight = const TextStyle(
    fontSize: 16,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w300, // Light
  );

  // Poppins SemiBold (19pt, weight: w600)
  static TextStyle PoppinsSemiBold = const TextStyle(
    fontSize: 19,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w600, // SemiBold
  );

  // Poppins Thin (14pt, weight: w100)
  static TextStyle PoppinsThin = const TextStyle(
    fontSize: 14,
    fontFamily:
        AppFonts.POPPINS, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w100, // Thin
  );

  // Poppins Light (16pt, weight: w300)
  static TextStyle EuropaLight = const TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.EUROPA, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w300, // Light
  );

  // Poppins SemiBold (19pt, weight: w600)
  static TextStyle EuropaBold = const TextStyle(
    fontSize: 15,
    fontFamily: AppFonts.EUROPA, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w700, // SemiBold
  );

  // Poppins Light (16pt, weight: w300)
  static TextStyle RobotoRegular = const TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.ROBOTO, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w400, // Light
  );

  // Poppins SemiBold (19pt, weight: w600)
  static TextStyle RobotoBold = const TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.ROBOTO, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w700, // SemiBold
  );

  // Poppins SemiBold (19pt, weight: w600)
  static TextStyle RobotoLight = const TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.ROBOTO, // Use the POPPINS font from the AppFonts class
    fontWeight: FontWeight.w300, // SemiBold
  );
}
