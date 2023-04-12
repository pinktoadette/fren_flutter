import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/api/notifications_api.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/app_notifications.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/storyboard/storyboard_home.dart';
import 'package:fren_app/tabs/conversations_tab.dart';
import 'package:fren_app/tabs/explore_bot_tabs.dart';
import 'package:fren_app/screens/notifications_screen.dart';
import 'package:fren_app/tabs/activity_tab.dart';
import 'package:fren_app/tabs/profile_tab.dart';
import 'package:fren_app/widgets/bot/my_bots.dart';
import 'package:fren_app/widgets/bot/prompt_create.dart';
import 'package:fren_app/widgets/button/action_button.dart';
import 'package:fren_app/widgets/button/expandable_fab.dart';
import 'package:fren_app/widgets/notification_counter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatController chatController = Get.find();
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();
  final _chatroomApi = ChatroomMachiApi();

  int _selectedIndex = 0;
  late AppLocalizations _i18n;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  // in_app_purchase stream
  // late StreamSubscription<List<PurchaseDetails>> _inAppPurchaseStream;

  @override
  void initState() {
    super.initState();

    /// Restore VIP Subscription
    AppHelper().restoreVipAccount();

    /// Init streams
    _getCurrentUserUpdates();

    // create a new room for quick chat
    _getChatrooms();

    // _handlePurchaseUpdates();
    _initFirebaseMessage();

    /// Request permission for IOS
    ///@todo should be saved in table rather than keep asking
    _requestPermissionForIOS();
  }

  @override
  void dispose() {
    super.dispose();
    // Close streams
    _userStream.drain();
    // _inAppPurchaseStream.cancel();
  }

  /// Update selected tab
  void _onTappedNavBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// get or create chatroom
  Future<void> _getChatrooms() async {
    await Future.wait(
            [_chatroomApi.createNewRoom(), _chatroomApi.getAllMyRooms()])
        .then((_) {})
        .whenComplete(() {
      debugPrint("Loaded new and all chatrooms");
    }).catchError((onError) {
      debugPrint(onError);
    });
  }

  /// Get current User Real Time updates
  void _getCurrentUserUpdates() {
    /// Get user stream
    _userStream = UserModel().getUserStream();

    /// Subscribe to user updates
    _userStream.listen((userEvent) {
      // Update user
      UserModel().updateUserObject(userEvent.data()!);
    });
  }

  Future<void> _handleNotificationClick(Map<String, dynamic>? data) async {
    /// Handle notification click
    await _appNotifications.onNotificationClick(
      context,
      nType: data?[NOTIF_TYPE] ?? '',
      nSenderId: data?[NOTIF_SENDER_ID] ?? '',
      nMessage: data?[NOTIF_MESSAGE] ?? '',
    );
  }

  /// Request permission for push notifications
  /// Only for iOS
  void _requestPermissionForIOS() async {
    if (Platform.isIOS) {
      // Request permission for iOS devices
      await FirebaseMessaging.instance.requestPermission();
    }
  }

  ///
  /// Handle incoming notifications while the app is in the Foreground
  ///
  Future<void> _initFirebaseMessage() async {
    // Get initial message if the application
    // has been opened from a terminated state.
    final message = await FirebaseMessaging.instance.getInitialMessage();
    // Check notification data
    if (message != null) {
      // Debug
      debugPrint('getInitialMessage() -> data: ${message.data}');
      // Handle notification data
      await _handleNotificationClick(message.data);
    }

    // Returns a [Stream] that is called when a user
    // presses a notification message displayed via FCM.
    // Note: A Stream event will be sent if the app has
    // opened from a background state (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Debug
      debugPrint('onMessageOpenedApp() -> data: ${message.data}');
      // Handle notification data
      await _handleNotificationClick(message.data);
    });

    // Listen for incoming push notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      // Debug
      debugPrint('onMessage() -> data: ${message?.data}');
      // Handle notification data
      await _handleNotificationClick(message?.data);
    });
  }

  /// Tab navigation
  Widget _showCurrentNavBar() {
    List<Widget> options = <Widget>[
      const ActivityTab(),
      ConversationsTab(),
      const Storyboard(),
      const ExploreBotTab(),
      const ProfileTab()
    ];

    return options.elementAt(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
                isDarkMode
                    ? "assets/images/logo_pink.png"
                    : "assets/images/machi.png",
                height: 40),
            const SizedBox(width: 10),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                icon: _getNotificationCounter(),
                onPressed: () async {
                  // Go to Notifications Screen
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationsScreen()));
                }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: Platform.isIOS ? 0 : 8,
          currentIndex: _selectedIndex,
          onTap: _onTappedNavBar,
          items: [
            /// Discover Tab
            BottomNavigationBarItem(
                label: _i18n.translate("activity"),
                icon: Icon(Iconsax.activity,
                    color: _selectedIndex == 0
                        ? Theme.of(context).primaryColor
                        : null)),

            /// Conversations Tab
            BottomNavigationBarItem(
              label: _i18n.translate("chat"),
              icon: _getConversationCounter(),
            ),

            /// Discover new machi
            BottomNavigationBarItem(
                label: _i18n.translate("story"),
                icon: Icon(Iconsax.book,
                    color: _selectedIndex == 2
                        ? Theme.of(context).primaryColor
                        : null)),

            /// Discover new machi
            BottomNavigationBarItem(
                label: "Machi",
                icon: Icon(Iconsax.search_favorite,
                    color: _selectedIndex == 3
                        ? Theme.of(context).primaryColor
                        : null)),

            /// Profile Tab
            BottomNavigationBarItem(
              label: _i18n.translate("profile"),
              icon: Icon(Iconsax.user,
                  color: _selectedIndex == 4
                      ? Theme.of(context).primaryColor
                      : null),
            ),
          ]),
      body: _showCurrentNavBar(),
      floatingActionButton: ExpandableFab(
        distance: 80.0,
        children: [
          ActionButton(
            onPressed: () => {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return const FractionallySizedBox(
                      heightFactor: 0.9, child: CreateMachiWidget());
                },
              )
            },
            icon: const Icon(Iconsax.pen_add),
          ),
          ActionButton(
            onPressed: () => {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return const FractionallySizedBox(
                      heightFactor: 0.9, child: MyMachiWidget());
                },
              )
            },
            icon: const Icon(Iconsax.note),
          ),
        ],
      ),
    );
  }

  /// Count unread notifications
  Widget _getNotificationCounter() {
    const icon = Icon(Iconsax.notification);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationsApi.getNotifications(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[NOTIF_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }

  /// Count unread conversations
  Widget _getConversationCounter() {
    // Set icon
    final icon = Icon(Iconsax.message,
        color: _selectedIndex == 1 ? Theme.of(context).primaryColor : null);

    return Obx(() {
      return chatController.unreadCounter.value == 0
          ? icon
          : NotificationCounter(
              icon: icon, counter: chatController.unreadCounter.value);
    });
  }
}
