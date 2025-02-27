import 'package:machi_app/constants/constants.dart';

class AppInfo {
  /// Variables
  final int androidAppCurrentVersion;
  final int iosAppCurrentVersion;
  final String androidPackageName;
  final String iOsAppId;
  final String appEmail;
  final String revenueCatAndriodIdentifier;
  final String privacyPolicyUrl;
  final String termsOfServicesUrl;
  final String firebaseServerKey;
  final List<String> subscriptionIds;
  final double freeAccountMaxDistance;
  final double vipAccountMaxDistance;
  // Custom variables
  final String agoraAppID;

  /// Constructor
  AppInfo({
    required this.androidAppCurrentVersion,
    required this.iosAppCurrentVersion,
    required this.androidPackageName,
    required this.revenueCatAndriodIdentifier,
    required this.iOsAppId,
    required this.appEmail,
    required this.privacyPolicyUrl,
    required this.termsOfServicesUrl,
    required this.firebaseServerKey,
    required this.subscriptionIds,
    required this.freeAccountMaxDistance,
    required this.vipAccountMaxDistance,
    // Custom variables
    required this.agoraAppID,
  });

  /// factory AppInfo object
  factory AppInfo.fromDocument(Map<String, dynamic> doc) {
    return AppInfo(
      androidAppCurrentVersion: doc[ANDROID_APP_CURRENT_VERSION] ?? 1,
      iosAppCurrentVersion: doc[IOS_APP_CURRENT_VERSION] ?? 1,
      androidPackageName: doc[ANDROID_PACKAGE_NAME] ?? 'machi',
      revenueCatAndriodIdentifier:
          doc[REVENUE_CAT_ANDROID_IDENTIFIER] ?? 'Imagine',
      iOsAppId: doc[IOS_APP_ID] ?? '',
      appEmail: doc[APP_EMAIL] ?? 'frankie@mymachi.app',
      privacyPolicyUrl: doc[PRIVACY_POLICY_URL] ?? '',
      termsOfServicesUrl: doc[TERMS_OF_SERVICE_URL] ?? '',
      firebaseServerKey: doc[FIREBASE_SERVER_KEY] ?? '',
      subscriptionIds: List<String>.from(doc[STORE_SUBSCRIPTION_IDS] ?? []),
      freeAccountMaxDistance: doc[FREE_ACCOUNT_MAX_DISTANCE] == null
          ? 100
          : doc[FREE_ACCOUNT_MAX_DISTANCE].toDouble(),
      vipAccountMaxDistance: doc[VIP_ACCOUNT_MAX_DISTANCE] == null
          ? 200
          : doc[VIP_ACCOUNT_MAX_DISTANCE].toDouble(),
      // Custom variables
      agoraAppID: doc['agora_app_id'] ?? '',
    );
  }
}
