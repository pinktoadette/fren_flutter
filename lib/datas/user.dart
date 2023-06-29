import 'package:machi_app/constants/constants.dart';

class User {
  /// User info
  final String userId;
  final bool isProfileFilled;
  final bool isFrankInitiated;
  final String userProfilePhoto;
  final String userFullname;
  final String userGender;
  final int userBirthDay;
  final int userBirthMonth;
  final int userBirthYear;
  final String username;
  final String userPhoneNumber;
  final String userEmail;
  final String userCountry;
  final String userStatus;
  final bool userIsVerified;
  final String userLevel;
  final DateTime userRegDate;
  final DateTime userLastUpdate;
  final DateTime userLastLogin;
  final String userDeviceToken;
  final List<String> userInterest;
  final String userIndustry;
  final String userJob;
  final bool isSubscribed;
  final String? userBio;
  final bool? isDarkMode;
  final bool? following;
  final int? followers;
  final int? followings;
  final Map<String, dynamic>? userGallery;
  final Map<String, dynamic>? userSettings;
  final Map<String, dynamic>? userEnableMode;

  // Constructor
  User(
      {required this.userId,
      required this.isFrankInitiated,
      required this.isProfileFilled,
      required this.userProfilePhoto,
      required this.userFullname,
      required this.userGender,
      required this.userBirthDay,
      required this.userBirthMonth,
      required this.userBirthYear,
      required this.username,
      required this.userBio,
      required this.userPhoneNumber,
      required this.userEmail,
      required this.userGallery,
      required this.userCountry,
      required this.userSettings,
      required this.userStatus,
      required this.userLevel,
      required this.userIsVerified,
      required this.userRegDate,
      required this.userLastLogin,
      required this.userLastUpdate,
      required this.userDeviceToken,
      required this.userEnableMode,
      required this.isDarkMode,
      required this.isSubscribed,
      required this.userInterest,
      required this.userIndustry,
      required this.userJob,
      required this.following,
      required this.followings,
      required this.followers});

  /// factory user object
  factory User.fromDocument(Map<String, dynamic> doc) {
    return User(
        userId: doc[USER_ID],
        isFrankInitiated: doc[USER_INITIATED_FRANK] ?? false,
        isProfileFilled: doc[USER_PROFILE_FILLED] ?? false,
        userProfilePhoto: doc[USER_PROFILE_PHOTO] ?? '',
        userFullname: doc[USER_FULLNAME],
        userGender: doc[USER_GENDER] ?? '',
        userBirthDay: doc[USER_BIRTH_DAY] ?? 1,
        userBirthMonth: doc[USER_BIRTH_MONTH] ?? 1,
        userBirthYear: doc[USER_BIRTH_YEAR] ?? 1990,
        username: doc[USER_USERNAME] ?? '',
        userJob: doc[USER_JOB] ?? '',
        userInterest: doc[USER_INTERESTS] ?? [],
        userIndustry: doc[USER_INDUSTRY] ?? '',
        userBio: doc[USER_BIO] ?? '',
        userEnableMode: doc[USER_ENABLE_MODE],
        userPhoneNumber: doc[USER_PHONE_NUMBER] ?? '',
        userEmail: doc[USER_EMAIL] ?? '',
        userGallery: doc[USER_GALLERY],
        userCountry: doc[USER_COUNTRY] ?? '',
        userSettings: doc[USER_SETTINGS],
        userStatus: doc[USER_STATUS] ?? 'active',
        userIsVerified: doc[USER_IS_VERIFIED] ?? false,
        userLevel: doc[USER_LEVEL] ?? 'user',
        isDarkMode: doc[USER_DARK_MODE] ?? false,
        isSubscribed: doc[USER_IS_SUBSCRIBED] ?? false,
        following: doc["following"] ?? false,
        followers: doc["followers"] ?? 0,
        followings: doc["followings"] ?? 0,
        userRegDate: doc[CREATED_AT] is int
            ? DateTime.fromMillisecondsSinceEpoch(doc[CREATED_AT])
            : doc.containsKey(CREATED_AT)
                ? doc[CREATED_AT].toDate()
                : DateTime.now(), // Firestore Timestamp vs mongo vs guest AUGH
        userLastLogin: doc[USER_LAST_LOGIN] is int
            ? DateTime.fromMillisecondsSinceEpoch(doc[USER_LAST_LOGIN])
            : doc.containsKey(CREATED_AT)
                ? doc[USER_LAST_LOGIN].toDate()
                : DateTime.now(),
        userLastUpdate: doc[UPDATED_AT] is int
            ? DateTime.fromMillisecondsSinceEpoch(doc[UPDATED_AT])
            : doc.containsKey(CREATED_AT)
                ? doc[UPDATED_AT].toDate()
                : DateTime.now(),
        userDeviceToken: doc[USER_DEVICE_TOKEN] ?? '');
  }
}
