import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/base_service.dart';


class ParentProfileService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser(UserModel user) async {
    // Get the currently authenticated user's UID
    String? userId = _auth.currentUser?.uid;
    final UserPreferences userPreferences = UserPreferences();

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    // Ensure the user model contains the correct userID
    final updatedUser = UserModel(
      userID: userId, // Set userID as Firebase Auth UID
      phoneNumber: user.phoneNumber,
      role: user.role,
      userAccountCreatedTime: user.userAccountCreatedTime,
    );
// saving user Id
//
    userPreferences.saveUserId(userId);

    var snapshot = await getDocument( CollectionKey.USER_COLLECTION,userId);

    if(!snapshot.exists) {

      await createDocument(
        CollectionKey.USER_COLLECTION,
        userId,
        updatedUser.toJson(),
      );

    }

    return !snapshot.exists;
  }

  Future<bool> addCafeteriaInfo(String name, String logo, String college) async {
    // Get the currently authenticated user's UID
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    var snapshot = await getDocument( CollectionKey.USER_COLLECTION,userId);


    var user = UserModel.fromJson(snapshot.data()!);

    user.cafeteriaName = name;
    user.cafeteriaLogo = logo;
    user.schoolName = college;

    await updateDocument(
      CollectionKey.USER_COLLECTION,
      userId,
      user.toJson(),
    );

    print('User Data 📈📈📈📈📈${user.toJson()}');

    // Get.offAllNamed(Routes.CAFETERIA_LANDING_PAGE);

    return !snapshot.exists;
  }
}
