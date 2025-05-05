import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

  // Initialize Stripe
  Stripe.publishableKey =
      'pk_test_51Qz5ao08zT37J1Lvgay2AfgAVN3ANqMnvc2MSsXKepaLSVF8EpV4iUwRkJVF06FsEYXOnQNnjg83NOfkVLTSv0Mv00kDI0wRJw';
  await Stripe.instance.applySettings();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase Analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Initialize services
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
