import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:snacktag/models/user_model.dart';
import 'package:snacktag/config/app_const.dart';
import 'package:snacktag/services/Shared_preference/preferences.dart';
import 'package:snacktag/services/base_service.dart';

class ParentsServices extends BaseService {
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
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('user_Id', userId);
    userPreferences.saveUserId(userId);

    var snapshot = await getDocument(CollectionKey.USER_COLLECTION, userId);

    print("Parent exists or not: ${snapshot.exists}");

// Print full snapshot data
    if (snapshot.exists) {
      print("Document Data: ${snapshot.data()}");
    } else {
      print("No document found for userId: $userId");
    }

    if (!snapshot.exists) {
      await createDocument(
        CollectionKey.USER_COLLECTION,
        userId,
        updatedUser.toJson(),
      );

      print("New document created for userId: $userId");


  }

    return !snapshot.exists;
  }

  Future<bool> addParentsInfo(String name, String logo,) async {
    // Get the currently authenticated user's UID
    print("parent name is $name and img path is ${logo}");
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    var snapshot = await getDocument( CollectionKey.USER_COLLECTION,userId);


    var user = UserModel.fromJson(snapshot.data()!);

    user.parentsName = name;
    user.parentsPic = logo;

    await updateDocument(
      CollectionKey.USER_COLLECTION,
      userId,
      user.toJson(),
    );

    // Get.offAllNamed(Routes.LANDING_PAGE);

    return !snapshot.exists;
  }
}
