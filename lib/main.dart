import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import 'package:snacktag/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:snacktag/app/modules/parents_children_details/controllers/parents_children_details_controller.dart';
import 'package:snacktag/widgets/custom_dialog_schedule.dart';
import 'package:snacktag/widgets/custom_shedule_dialog.dart';
import 'package:snacktag/services/cloud_functions_service.dart';
import 'package:snacktag/services/notifications_service/notifications_service.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';
import 'package:snacktag/app/modules/staff_phone_verification/controllers/staff_phone_verification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check BEFORE any other Firebase services
  try {
    // For debug builds, use the debug provider
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        // Debug provider
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      print('✅ Firebase App Check initialized in debug mode');
    } else {
      // For release builds, use the appropriate provider
      await FirebaseAppCheck.instance.activate(
        // Production providers
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      print('✅ Firebase App Check initialized in production mode');
    }

    // Enable token auto refresh
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

    // Verify App Check is working
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      print('✅ App Check token obtained successfully: ${token != null}');
    } catch (e) {
      print('❌ Error getting App Check token: $e');
    }
  } catch (e) {
    print('❌ Error initializing Firebase App Check: $e');
    // Continue with app initialization even if App Check fails
  }

  // Initialize Stripe
  Stripe.publishableKey =
      'pk_test_51Qz5ao08zT37J1Lvgay2AfgAVN3ANqMnvc2MSsXKepaLSVF8EpV4iUwRkJVF06FsEYXOnQNnjg83NOfkVLTSv0Mv00kDI0wRJw';
  await Stripe.instance.applySettings();

  // Initialize other services
  Get.put(CloudFunctionsService());
  Get.put(NotificationService());

  Get.put(ScheduleDialogController());
  Get.put(ScheduleSelectedDialogController()); // Register the controller
  Get.put(StaffPhoneVerificationController());
  Get.put(ParentsChildrenDetailsController()); // Add this line
  Get.put(NotificationsController()); // Add notifications controller

  runApp(
    GetMaterialApp(
      title: "Snack Tag",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
