// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// APP SETINGS INFO CONSTANTS - SECTION ///
///
const String APP_NAME = "machi";
const Color APP_PRIMARY_COLOR = Colors.black;
const Color APP_MUTED_COLOR = Colors.black12;
const Color APP_ACCENT_COLOR = Color.fromARGB(255, 236, 85, 136);
const Color APP_PRIMARY_BACKGROUND = Colors.white;
const Color APP_SUCCESS = Color.fromARGB(255, 85,236,110);
const Color APP_WARNING = Color.fromARGB(255, 236,185,85);
const Color APP_INFO = Color.fromARGB(255, 85,212,236);
const Color APP_ERROR = Color.fromARGB(255, 236,110,85);
const String APP_VERSION_NAME = "Android v1.0.0 & iOS v1.0.0";
const int ANDROID_APP_VERSION_NUMBER = 1; // Google Play Version Number
const int IOS_APP_VERSION_NUMBER = 1; // App Store Version Number
//
// Add Google Maps - API KEY required for Passport feature
//
const String ANDROID_MAPS_API_KEY = "YOUR ANDROID API KEY";
const String IOS_MAPS_API_KEY = "YOUR IOS API KEY";
//
// GOOGLE ADMOB INTERSTITIAL IDS
//
// For Android Platform
const String ANDROID_INTERSTITIAL_ID = "YOUR ANDROID AD ID";
// For IOS Platform
const String IOS_INTERSTITIAL_ID = "YOUR iOS AD ID";

const PY_API = "https://machi.herokuapp.com/api/";

/// List of Supported Locales
/// Add your new supported Locale to the array list.
///
/// E.g: Locale('fr'), Locale('es'),
///
const List<Locale> SUPPORTED_LOCALES = [
  Locale('en'),
];

///
/// END APP SETINGS - SECTION

///
/// DATABASE COLLECTIONS FIELD - SECTION
///
/// FIREBASE MESSAGING TOPIC
const NOTIFY_USERS = "NOTIFY_USERS";

/// Bot
const DEFAULT_BOT_ID = 'Bot_GgQ0c3cqypSmKcpfUA9M';
const DEFAULT_BOT_INTRO_ID = 'DEFAULT_BOT_ID';

/// Bot Database Collection
const BOT_ID = 'botId';
const BOT_ABOUT = "about";
const BOT_NAME = 'name';
const BOT_PROFILE_PHOTO = 'photo';
const BOT_REPO_ID = 'repoId';
const BOT_MODEL = 'model';
const BOT_DOMAIN = "domain";
const BOT_SUBDOMAIN = 'subdomain';
const BOT_OWNER_ID = 'ownerId';
const BOT_PRICE = "price";
const BOT_PRICE_UNIT = "priceInit"; //
const BOT_ACTIVE = "isActive";
const BOT_ACTIVE_STATUS = "activeStatus"; //pause ?
const BOT_ADMIN_STATUS = "adminStatus";
const BOT_ADMIN_NOTE = "adminNote";

/// trials
const BOT_TRIAL_BOT_ID = BOT_ID;
const BOT_TRIAL_OWNER_ID = "bot_trial_user_id";
const BOT_TRIAL_TIMES = "bot_trial_times"; // counter for how many times user tried

/// upload pathings
const C_AI_IMAGE_PATH = "AiImage";

/// DATABASE COLLECTION NAMES USED IN APP
///
const String C_APP_INFO = "AppInfo";
const String C_USERS = "Users";
const String C_BOT = "Bots";
const String C_BOT_WALKTHRU = "DiscoverCards";
const String C_BOT_USER_MATCH = "BotUserMatch";
const String C_CHATROOM = "Chatroom";
const String C_BOT_TRIALS  = "BotTrials";
const String C_FLAGGED_USERS = "FlaggedUsers";
const String C_CONNECTIONS = "Connections";
const String C_MATCHES = "Matches";
const String C_CONVERSATIONS = "Conversations";
const String C_LIKES = "Likes";
const String C_VISITS = "Visits";
const String C_DISLIKES = "Dislikes";
const String C_MESSAGES = "Messages";
const String C_NOTIFICATIONS = "Notifications";
const String C_BLOCKED_USERS = 'BlockedUsers';

/// DATABASE FIELDS FOR AppInfo COLLECTION  ///
///
const String ANDROID_APP_CURRENT_VERSION = "android_app_current_version";
const String IOS_APP_CURRENT_VERSION = "ios_app_current_version";
const String ANDROID_PACKAGE_NAME = "android_package_name";
const String IOS_APP_ID = "ios_app_id";
const String APP_EMAIL = "app_email";
const String PRIVACY_POLICY_URL = "privacy_policy_url";
const String TERMS_OF_SERVICE_URL = "terms_of_service_url";
const String FIREBASE_SERVER_KEY = "firebase_server_key";
const String STORE_SUBSCRIPTION_IDS = "store_subscription_ids";
const String FREE_ACCOUNT_MAX_DISTANCE = "free_account_max_distance";
const String VIP_ACCOUNT_MAX_DISTANCE = "vip_account_max_distance";
// Admob variables
const String ADMOB_APP_ID = "admob_app_id";
const String ADMOB_INTERSTITIAL_AD_ID = "admob_interstitial_ad_id";

/// DATABASE FIELDS FOR USER COLLECTION  ///
///
const String USER_ID = "userId";
const String USER_INITIATED_FRANK = "initiatedFrank";
const String USER_ENABLE_MODE = "enablMode";
const String USER_PROFILE_FILLED = "profileFilled";
const String USER_PROFILE_PHOTO = "photoUrl";
const String USER_FULLNAME = "fullname";
const String USER_GENDER = "gender";
const String USER_BIRTH_DAY = "birthDay";
const String USER_BIRTH_MONTH = "birthMonth";
const String USER_BIRTH_YEAR = "birthYear";
const String USER_SCHOOL = "school";
const String USER_INDUSTRY = "industry";
const String USER_JOB = "job";
const String USER_INTERESTS = "interests";
const String USER_BIO = "bio";
const String USER_PHONE_NUMBER = "phoneNumber";
const String USER_EMAIL = "email";
const String USER_GALLERY = "gallery";
const String USER_COUNTRY = "country";
const String USER_LOCALITY = "locality";
const String USER_GEO_POINT = "geoPoint";
const String USER_SETTINGS = "settings";
const String USER_STATUS = "status";
const String USER_IS_VERIFIED = "isVerified";
const String USER_LEVEL = "level";
const String USER_LAST_UPDATE = "lastUpdate";
const String USER_LAST_LOGIN = "lastLogin";
const String USER_DEVICE_TOKEN = "deviceToken";
const String USER_TOTAL_LIKES = "totalLikes";
const String USER_TOTAL_VISITS = "totalVisits";
const String USER_TOTAL_DISLIKED = "totalDisliked";
// User Setting map - fields
const String USER_MIN_AGE = "minAge";
const String USER_MAX_AGE = "maxAge";
const String USER_MAX_DISTANCE = "maxDistance";
const String USER_SHOW_ME = "showMe";
// Enabled model
const String USER_ENABLE_DATE = "enableDate";
const String USER_ENABLE_SERV = "enableService";

/// DATABASE FIELDS FOR FlaggedUsers COLLECTION  ///
///
const String FLAGGED_USER_ID = "flaggedUserId";
const String FLAG_REASON = "flaggedReason";
const String FLAGGED_BY_USER_ID = "flaggedByUserId";

/// DATABASE FIELDS FOR Messages and Conversations COLLECTION ///
///
const String MESSAGE_TEXT = "message_text";
const String MESSAGE_TYPE = "message_type";
const String MESSAGE_IMG_LINK = "message_img_link";
const String MESSAGE_READ = "message_read";
const String LAST_MESSAGE = "last_message";

/// DATABASE FIELDS FOR Notifications COLLECTION ///
///
const N_SENDER_ID = "n_sender_id";
const N_SENDER_FULLNAME = "n_sender_fullname";
const N_SENDER_PHOTO_LINK = "n_sender_photo_link";
const N_RECEIVER_ID = "n_receiver_id";
const N_TYPE = "n_type";
const N_MESSAGE = "n_message";
const N_READ = "n_read";

/// DATABASE FIELDS FOR Likes COLLECTION
///
const String LIKED_USER_ID = 'likedUserId';
const String LIKED_BY_USER_ID = 'likedByUserId';
const String LIKE_TYPE = 'likeType';

/// DATABASE FIELDS FOR Dislikes COLLECTION
///
const String DISLIKED_USER_ID = 'disliked_user_id';
const String DISLIKED_BY_USER_ID = 'disliked_by_user_id';

/// DATABASE FIELDS FOR Visits COLLECTION
///
const String VISITED_USER_ID = 'visited_user_id';
const String VISITED_BY_USER_ID = 'visited_by_user_id';

/// DATABASE FIELDS FOR [BlockedUsers] (NEW) COLLECTION
///
const String BLOCKED_USER_ID = 'blockedUserId';
const String BLOCKED_BY_USER_ID = 'blockedByUserId';

/// DATABASE SHARED FIELDS FOR COLLECTION
///
const String TIMESTAMP = "timestamp";
const String UPDATED_AT = "updatedAt";
const String CREATED_AT = "createdAt";