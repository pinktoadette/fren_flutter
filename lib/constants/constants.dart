// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const String env = 'prod';

const PY_DEV = "https://machi-dev-yiuw6.ondigitalocean.app/api/";
const PY_UAT = "https://machi-uat-onn4q.ondigitalocean.app/api/";
const PY_PROD = "https://api.mymachi.app/api/";

const PY_API = env == 'prod'
    ? PY_PROD
    : env == 'uat'
        ? PY_UAT
        : PY_DEV;
const SOCKET_WS_DEV = "wss://machi-dev-yiuw6.ondigitalocean.app/";

// const SOCKET_WS = "wss://api.mymachi.app/";
const SOCKET_WS = SOCKET_WS_DEV;

/// APP SETINGS INFO CONSTANTS - SECTION ///
///
const String APP_NAME = "machi";
const Color APP_PRIMARY_COLOR = Colors.black;
const Color APP_MUTED_COLOR = Color.fromARGB(120, 250, 250, 250);
const Color APP_ACCENT_COLOR = Color.fromARGB(255, 33, 202, 137);
const Color APP_SECONDARY_ACCENT_COLOR = Color.fromARGB(255, 202, 137, 33);
const Color APP_LIKE_COLOR = Color.fromARGB(255, 236, 85, 136);
const Color APP_PRIMARY_BACKGROUND = Colors.white;
const Color APP_INVERSE_PRIMARY_COLOR = Color.fromARGB(255, 196, 196, 196);
const Color APP_INPUT_COLOR = Color.fromARGB(255, 26, 26, 26);
const Color APP_TERTIARY = Color.fromARGB(255, 30, 30, 30);
const Color APP_SUCCESS = Color.fromARGB(255, 33, 202, 137);
const Color APP_WARNING = Color.fromARGB(255, 236, 185, 85);
const Color APP_INFO = Color.fromARGB(255, 33, 183, 202);
const Color APP_ERROR = Color.fromARGB(255, 202, 33, 98);
const String APP_VERSION_NAME = "Android v1.0.0 & iOS v1.0.0";
const int ANDROID_APP_VERSION_NUMBER = 1; // Google Play Version Number
const int IOS_APP_VERSION_NUMBER = 1; // App Store Version Number

const String GOOGLE_BANNER_ADS_ANDROID =
    'ca-app-pub-8475595365680681/9246193145';
const String GOOGLE_BANNER_ADS_IOS = 'ca-app-pub-8475595365680681/3096803874';
// test: 'ca-app-pub-3940256099942544/6300978111'; //live: ca-app-pub-8475595365680681/9246193145
const String GOOGLE_INTERSTI_ADS_ANDROID =
    'ca-app-pub-3940256099942544/8691691433';
// For IOS Platform
const String IOS_INTERSTITIAL_ID = "YOUR iOS AD ID";

//
// Add Google Maps - API KEY required for Passport feature
//
const String ANDROID_MAPS_API_KEY = "YOUR ANDROID API KEY";
const String IOS_MAPS_API_KEY = "YOUR IOS API KEY";
//
// GOOGLE ADMOB INTERSTITIAL IDS
//
// For Android Platform
const double AD_HEIGHT = 80;

const String SURVEY_FORM =
    "https://docs.google.com/forms/d/e/1FAIpQLSes0yj-Puf53h-GAJScJKsTDSoVjkyM1qTrEanFXEEhc767Jg/viewform?usp=sf_link";

/// Subscription symbol
const String SUB_TOKEN_IDENTIFIER = "token_";

const double PLAY_BUTTON_WIDTH = 45;
const int PAGE_CHAT_LIMIT = 10; //check with backend
const int ALL_PAGE_SIZE = 20;

const UPLOAD_PATH_BOARD = "board";
const UPLOAD_PATH_SCRIPT_IMAGE = "script";
const UPLOAD_PATH_COLLECTION = "collection";
const UPLOAD_PATH_MESSAGE = "message";
const UPLOAD_PATH_USER_PROFILE = "profile";
const UPLOAD_PATH_BOT_IMAGE = "machi";

/// List of Supported Locales
/// Add your new supported Locale to the array list.
///
/// E.g: Locale('fr'), Locale('es'),
///
const List<Locale> SUPPORTED_LOCALES = [
  Locale('en'),
];

///
/// Subscription - Revenue Cat
/// Reference: https://www.revenuecat.com/blog/engineering/flutter-subscriptions-tutorial/
const entitlementID = 'Premium';
const googleApiKey = "goog_jAIlfHZWRiuTKpiMgFaYSTIhNea";
const footerText =
    """A purchase will be applied to your account upon confirmation of the amount selected. Subscriptions will automatically renew unless canceled within 24 hours of the end of the current period. You can cancel any time using your account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.""";

///
/// END APP SETINGS - SECTION

///
/// DATABASE COLLECTIONS FIELD - SECTION
///
/// FIREBASE MESSAGING TOPIC
const NOTIFY_USERS = "NOTIFY_USERS";

/// Bot chat returned speed in multi user
const BOT_RESPONSE_SPEED_MIN = 5; //5 mins

/// Bot
const DEFAULT_BOT_ID = 'Machi_GgQ0c3cqypSmKcpfUA9M';
const DEFAULT_BOT_INTRO_ID = 'DEFAULT_BOT_ID';
const BOT_PREFIX = "Machi_";

/// Bot Database Collection
const BOT_INFO = 'machi';
const BOT_ID = 'botId';
const BOT_ABOUT = "about";
const BOT_NAME = 'name';
const BOT_PROFILE_PHOTO = 'photoUrl';
const BOT_MODEL = 'model';
const BOT_MODEL_TYPE = "modelType";
const BOT_CATEGORY = "category";
const BOT_DOMAIN = "domain";
const BOT_SUBDOMAIN = 'subdomain';
const BOT_OWNER_ID = 'ownerId';
const BOT_PRICE = "price";
const BOT_PRICE_UNIT = "priceUnit"; //
const BOT_ACTIVE = "isActive";
const BOT_ACTIVE_STATUS = "activeStatus"; //pause ?
const BOT_ADMIN_STATUS = "adminStatus";
const BOT_ADMIN_NOTE = "adminNote";
const BOT_PROMPT = "prompt";
const BOT_TEMPERATURE = "temperature";
const BOT_IS_PRIVATE = "isPrivate";
const BOT_CREATED_BY = "createdBy";

/// DATABASE COLLECTION NAMES USED IN APP
///
const String C_APP_INFO = "AppInfo";
const String C_USERS = "Users";
const String C_BOT = "Bots";
const String C_BOT_WALKTHRU = "DiscoverCards";
const String C_BOT_USER_MATCH = "BotUserMatch";
const String C_CHATROOM = "Chatroom";
const String C_BOT_TRIALS = "BotTrials";
const String C_FLAGGED_USERS = "FlaggedUsers";
const String C_CONNECTIONS = "Connections";
const String C_MATCHES = "Matches";
const String C_CONVERSATIONS = "Conversations";
const String C_VISITS = "Visits";
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
const String REVENUE_CAT_ANDROID_IDENTIFIER = "sub_android_identifier";

// Admob variables
const String ADMOB_APP_ID = "admob_app_id";
const String ADMOB_INTERSTITIAL_AD_ID = "admob_interstitial_ad_id";

const String FB_UID = "uid";

/// DATABASE FIELDS FOR USER COLLECTION  ///

const String USER_ID = "userId";
const String USER_INITIATED_FRANK = "initiatedFrank";
const String USER_ENABLE_MODE = "enablMode";
const String USER_PROFILE_FILLED = "isProfileFilled";
const String USER_PROFILE_PHOTO = "photoUrl";
const String USER_FULLNAME = "fullname";
const String USER_USERNAME = "username";
const String USER_GENDER = "gender";
const String USER_BIRTH_DAY = "birthDay";
const String USER_BIRTH_MONTH = "birthMonth";
const String USER_BIRTH_YEAR = "birthYear";
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
const String USER_DARK_MODE = "isDarkMode";
const String USER_IS_VERIFIED = "isVerified";
const String USER_LEVEL = "level";
const String USER_LAST_UPDATE = "lastUpdate";
const String USER_LAST_LOGIN = "lastLogin";
const String USER_DEVICE_TOKEN = "deviceToken";
const String USER_IS_SUBSCRIBED = "isSubscribed";

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
const String MESSAGE_IMAGE = "image";
const String MESSAGE_IMAGE_HEIGHT = "height";
const String MESSAGE_IMAGE_WIDTH = "width";
const String MESSAGE_IMAGE_URI = "uri";
const String MESSAGE_IMAGE_SIZE = "size";
const String MESSAGE_IMG_LINK = "message_img_link";
const String MESSAGE_READ = "read";
const String LAST_MESSAGE = "last_message";

/// DATABASE FIELDS FOR Notifications COLLECTION ///
///
const NOTIF_SENDER_ID = "senderId";
const NOTIF_SENDER_USERNAME = "senderUsername";
const NOTIF_SENDER_PHOTO_LINK = "senderPhoto";
const NOTIF_RECEIVER_ID = "receiverId";
const NOTIF_TYPE = "type";
const NOTIF_MESSAGE = "message";
const NOTIF_READ = "read";

/// FRIENDS
const FRIEND_STATUS = "status";

/// DATABASE FIELDS FOR [BlockedUsers] (NEW) COLLECTION
///
const String BLOCKED_USER_ID = 'blockedUserId';
const String BLOCKED_BY_USER_ID = 'blockedByUserId';

/// DATABASE SHARED FIELDS FOR COLLECTION
///
const String TIMESTAMP = "timestamp";
const String UPDATED_AT = "updatedAt";
const String CREATED_AT = "createdAt";
const String LIMIT = "limit";
const String OFFSET = "offset";

/// storyboard
const String STORYBOARD_ID = "storyboardId";
const String STORYBOARD_STATUS = "status";
const String STORYBOARD_TITLE = "title";
const String STORYBOARD_SUBTITLE = "subtitle";
const String STORYBOARD_CATEGORY = "category";
const String STORYBOARD_SUMMARY = "summary";
const String STORYBOARD_CREATED_BY = "createdBy";
const String STORYBOARD_PHOTO_URL = "photoUrl";

/// story
const String STORY = "story";
const String STORY_TITLE = "title";
const String STORY_SUBTITLE = "subtitle";
const String STORY_SUMMARY = "summary";
const String STORY_ID = "storyId";
const String STORY_CREATED_BY = "createdBy";
const String STORY_STATUS = "status";
const String STORY_PHOTO_URL = "photoUrl";
const String STORY_CATEGORY = "category";
const String STORY_LAYOUT = "layout";
const String STORY_BITS = "bits";
const String STORY_COVER_PAGES = "coverPages";
const String STORY_PAGES_BACKGROUND = "backgroundUrl";

/// Script
const String STORY_SCRIPT_PAGES = "pages";
const String SCRIPTS = "scripts";
const String SCRIPT_ID = "scriptId";
const String SCRIPT_TYPE = "type";
const String SCRIPT_TEXT = "text";
const String SCRIPT_IMAGE = "image";
const String SCRIPT_IMAGE_WIDTH = "width";
const String SCRIPT_IMAGE_HEIGHT = "height";
const String SCRIPT_IMAGE_SIZE = "size";
const String SCRIPT_IMAGE_URI = "uri";
const String SCRIPT_STATUS = "status";
const String SCRIPT_SPEAKER_NAME = "character";
const String SCRIPT_SPEAKER_USER_ID = "characterId";
const String SCRIPT_CREATED_BY = "createdBy";
const String SCRIPT_VOICE_INFO = "speaker";
const String SCRIPT_SEQUENCE_NUM = "seqNum";
const String SCRIPT_PAGE_NUM = "pageNum";

/// Voiceover
const String VOICE_OVER_ID = "voiceId";
const String VOICE_PROVIDER = "provider";
const String VOICE_JSON = "jsonData";
const String VOICE_NAME = "voiceName";

//// Replies
const String STORY_COMMENT = "comment";
const String COMMENT_ID = "commentId";
const String COMMENT_COUNT = "commentCount";
const String COMMENT_REPLY_TO_ID = "replyCommentId";
const String COMMENT_REPLY_TO_USER_ID = "userId";
const String COMMENT_RESPONSES = "responses";

/// Likes
const String ITEM_MY_LIKES = "mylikes";
const String ITEM_LIKES = "likes";

/// Report
const String REPORT = "report";
const String REPORT_SUBMITTED_BY = "user";
const String REPORT_REASON = "reason";
const String REPORT_ID = "reportId";
const String REPORT__ID = "report_id";
const String REPORT_ITEM_ID = "itemId";
const String REPORT_ITEM_TYPE = "itemType";
const String REPORT_COMMENTS = "comments";

/// subscription
const String SUBSCRIBED_AT = "subscribedAt";
const String IS_SUBSCRIBED = "subscribed";
const String SUBSCRIBED_MACHI = "mymachi";
const String UPSELL_AFFORDABLE = "imaginfy50";
const String UPSELL_BULK = "imaginfy200";

/// chatroom
const String FLUTTER_UI_ID = "id"; //fluter_chat_ui id
const String ROOM_ID = "chatroomId";
const String ROOM_HAS_MESSAGES = "hasMessages";
const String ROOM_TITLE = "title";
const String ROOM_CREATED_BY = "createdBy";
const String ROOM_TYPE = "roomType";

/// chat
const int GROUP_TIMER = 1;
const String CHAT_AUTHOR_ID = "authorId";
const String CHAT_AUTHOR = "author";
const String CHAT_USER_NAME = "name";
const String CHAT_TEXT = "text";
const String CHAT_IMAGE = "image";
const String CHAT_FILE = "file";
const String CHAT_TYPE = "type";
const String CHAT_MESSAGE_ID = "messageId";
const String CHAT_PHOTO_URL = "uri";
const String CHAT_LINKED_MESSAGE_ID = "linkedMessageId";
const String CHAT_MESSAGE_TAGS = "tags";
const String SLASH_IMAGINE = "/imagine";
const String SLASH_REIMAGINE = "/reimagine";
const String SLASH_BOARD = "/board";

/// gallery
const String GALLERY = "gallery";
const String GALLERY_IMAGE_CAPTION = "caption";
const String GALLERY_IMAGE_URL = "photoUrl";
