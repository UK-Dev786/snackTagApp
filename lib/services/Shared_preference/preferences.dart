import 'dart:convert';

import 'package:snacktag/models/cefeteria_admin/staff_model.dart';
import 'package:snacktag/models/staff/staff_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> removeUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }

  Future<void> saveStaffDataPreference(StaffModel staffDataModel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the staff data model to a map
    Map<String, dynamic> staffDataMap = staffDataModel.toMap();

    // Convert the map to a JSON string to store in SharedPreferences
    String staffDataJson = json.encode(staffDataMap);

    // Save the JSON string in SharedPreferences
    await prefs.setString('staffData', staffDataJson);
  }

// Get StaffDataModel from SharedPreferences
  Future<StaffModel?> getStaffDataPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? staffDataJson = prefs.getString('staffData');

    if (staffDataJson != null) {
      // Decode the JSON string back to a Map
      Map<String, dynamic> staffDataMap = jsonDecode(staffDataJson);
      String? staffId = staffDataMap['id']; // Use the map to create a StaffDataModel
      return StaffModel.fromMap(staffId, staffDataMap);
    }
    return null; // Return null if no staff data is stored
  }

  // Remove StaffData from SharedPreferences
  Future<void> removeStaffDataPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('staffData');
  }
}
