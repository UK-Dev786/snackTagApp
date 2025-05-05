import 'package:get/get.dart';
import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/staff/staff_profile_update_service.dart';

class StaffProfileController extends GetxController {
  final StaffProfileUpdateService _profileService = StaffProfileUpdateService();
  final UserPreferences preferences = UserPreferences();

  final staffModel = Rxn<StaffModel>();
  final adminData = Rxn<UserModel>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    print("StaffProfileController: onInit called");
    getStaffData();
  }

  @override
  void onReady() {
    super.onReady();
    // This will be called when the screen becomes visible
    // Useful for refreshing data when returning from another screen
    getStaffData();
  }

  // Method to refresh data when returning from edit screen
  void refreshData() {
    getStaffData();
  }

  Future<void> getStaffData() async {
    try {
      isLoading.value = true;
      final data = await preferences.getStaffDataPreference();

      if (data != null) {
        staffModel.value = data;
        print("Staff Data Retrieved Successfully:");
        print("Staff Name: ${data.staffName}");
        print("Staff User ID: ${data.userId}");
        print("Staff Image URL: ${data.imageUrl}");

        // Fetch admin data using staff's userId
        await getAdminData(data.userId);
      } else {
        print("No staff data found in preferences");
      }
    } catch (e) {
      print("Error fetching staff data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAdminData(String? adminUserId) async {
    try {
      if (adminUserId == null) {
        print("Admin User ID is null");
        return;
      }

      final adminUserData = await _profileService.getAdminData(adminUserId);
      if (adminUserData != null) {
        adminData.value = adminUserData;
        print("Admin Data Retrieved Successfully:");
        print("Cafeteria Name: ${adminData.value?.cafeteriaName}");
        print("School Name: ${adminData.value?.schoolName}");
      }
    } catch (e) {
      print("Error fetching admin data: $e");
    }
  }
}
