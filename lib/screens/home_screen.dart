import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/app_notifications.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/storyboard/storyboard_home.dart';
import 'package:machi_app/tabs/conversations_tab.dart';
import 'package:machi_app/tabs/activity_tab.dart';
import 'package:machi_app/tabs/profile_tab.dart';
import 'package:machi_app/widgets/bot/explore_bot.dart';
import 'package:machi_app/widgets/bot/prompt_create.dart';
import 'package:machi_app/widgets/button/action_button.dart';
import 'package:machi_app/widgets/button/expandable_fab.dart';
import 'package:machi_app/widgets/notification_counter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:machi_app/controller/bot_controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatController chatController = Get.find(tag: 'chatroom');
  final BotController botController = Get.find(tag: 'bot');
  final StoryboardController storyController = Get.find(tag: 'storyboard');
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');

  final _appNotifications = AppNotifications();
  final _chatroomApi = ChatroomMachiApi();

  int _selectedIndex = 0;
  late AppLocalizations _i18n;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  bool isFabOpen = false;

  @override
  void initState() {
    /// initialize states
    _initializeState();

    super.initState();

    /// Revenue Cat
    _fetchUserPlans();

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

  void _initializeState() {
    botController.fetchCurrentBot(DEFAULT_BOT_ID);
    chatController.initUser();
    chatController.onChatLoad();
    storyController.getBoards(filter: StoryStatus.UNPUBLISHED);
  }

  void _fetchUserPlans() async {
    try {
      String userId = UserModel().user.userId;
      await Purchases.logIn(userId);
      subscribeController.initUser();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  /// get or create chatroom
  Future<void> _getChatrooms() async {
    await Future.wait([
      _chatroomApi.createNewRoom(),
      _chatroomApi.getAllMyRooms(page: 1, clearRooms: true)
    ]).then((_) {}).whenComplete(() {
      debugPrint("Loaded new and all chatrooms");
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
      // const PlaylistTab(),
      const StoryboardHome(),
      const ConversationsTab(),
      const ProfileTab()
    ];

    return options.elementAt(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: Platform.isIOS ? 0 : 8,
            currentIndex: _selectedIndex,
            backgroundColor: Colors.black,
            selectedItemColor: APP_ACCENT_COLOR,
            unselectedItemColor:
                Theme.of(context).colorScheme.primary.withAlpha(155),
            onTap: _onTappedNavBar,
            items: [
              /// Discover Tab
              BottomNavigationBarItem(
                  label: _i18n.translate("discover"),
                  icon: const Icon(
                    Iconsax.activity,
                  )),

              /// Discover new machi
              BottomNavigationBarItem(
                  label: _i18n.translate("storyboard"),
                  icon: const Icon(Iconsax.book)),

              /// Conversations Tab
              BottomNavigationBarItem(
                label: _i18n.translate("chat"),
                icon: _getConversationCounter(),
              ),

              /// Profile Tab
              BottomNavigationBarItem(
                  label: _i18n.translate("profile"),
                  icon: const Icon(Iconsax.user)),
            ]),
        body: _showCurrentNavBar(),
        floatingActionButton: ExpandableFab(
          isOpen: isFabOpen,
          distance: 80.0,
          children: [
            ActionButton(
              onPressed: () => {
                showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FractionallySizedBox(
                        heightFactor: 0.9,
                        child: DraggableScrollableSheet(
                          snap: true,
                          initialChildSize: 1,
                          minChildSize: 1,
                          builder: (context, scrollController) =>
                              SingleChildScrollView(
                            controller: scrollController,
                            child: const CreateMachiWidget(),
                          ),
                        ))),
                setState(() {
                  isFabOpen = false;
                })
              },
              icon: const Icon(Iconsax.pen_add),
            ),
            ActionButton(
              onPressed: () => {
                showModalBottomSheet<void>(
                  context: context,
                  enableDrag: true,
                  isScrollControlled: true,
                  builder: (context) {
                    return const FractionallySizedBox(
                        heightFactor: 0.9, child: ExploreMachi());
                  },
                ),
                setState(() {
                  isFabOpen = false;
                })
              },
              icon: const Icon(Iconsax.note),
            ),
          ],
        ));
  }

  /// Count unread conversations
  Widget _getConversationCounter() {
    // Set icon
    final icon = Icon(Iconsax.message,
        color: _selectedIndex == 2 ? APP_ACCENT_COLOR : null);

    return Obx(() {
      return chatController.unreadCounter.value == 0
          ? icon
          : NotificationCounter(
              icon: icon, counter: chatController.unreadCounter.value);
    });
  }
}
