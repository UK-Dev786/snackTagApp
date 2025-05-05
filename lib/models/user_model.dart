import 'package:snacktag/config/app_const.dart';

class UserModel {
  final String? userID;
  final String? phoneNumber;
  final String? role;
  final DateTime? userAccountCreatedTime;
   String? cafeteriaName;
   String? schoolName;
   String? cafeteriaLogo;
   String? parentsName;
   String? parentsPic;


  UserModel({
    this.userID,
    this.phoneNumber,
    this.role,
    this.userAccountCreatedTime,
    this.cafeteriaName,
    this.schoolName,
    this.parentsName,
    this.parentsPic,

    this.cafeteriaLogo,
  });

  Map<String, dynamic> toJson() {
    return {
      UserKey.USER_ID: userID,
      UserKey.PHONE_NUMBER: phoneNumber,
      UserKey.ROLE: role,
      UserKey.USER_ACCOUNT_CREATED_TIME:
          userAccountCreatedTime?.toIso8601String(),
      UserKey.CAFETERIA_LOGO: cafeteriaLogo,
      UserKey.SCHOOL_NAME: schoolName,
      UserKey.PARENTS_NAME: parentsName,
      UserKey.PARENTS_PIC: parentsPic,
      UserKey.CAFETERIA_NAME: cafeteriaName,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userID: json[UserKey.USER_ID] as String?,
      phoneNumber: json[UserKey.PHONE_NUMBER] as String?,
      role: json[UserKey.ROLE] as String?,
      userAccountCreatedTime: json[UserKey.USER_ACCOUNT_CREATED_TIME] != null
          ? DateTime.tryParse(json[UserKey.USER_ACCOUNT_CREATED_TIME])
          : null,
      cafeteriaLogo: json[UserKey.CAFETERIA_LOGO] as String?,
      schoolName: json[UserKey.SCHOOL_NAME] as String?,
      parentsName: json[UserKey.PARENTS_NAME] as String?,
      parentsPic: json[UserKey.PARENTS_PIC] as String?,
      cafeteriaName: json[UserKey.CAFETERIA_NAME] as String?,
    );
  }
}
