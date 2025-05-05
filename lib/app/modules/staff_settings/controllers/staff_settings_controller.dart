import 'package:get/get.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffSettingsController extends GetxController {
  Future<void> removeUserId() async {
    UserPreferences preferences = UserPreferences();
    preferences.removeStaffDataPreference();
    preferences.removeUserId();
  }
}
