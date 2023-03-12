import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fren_app/api/conversations_api.dart';
import 'package:fren_app/api/notifications_api.dart';
import 'package:fren_app/helpers/app_helper.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/helpers/app_notifications.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/bot/bot_chat.dart';
import 'package:fren_app/tabs/notifications_screen.dart';
import 'package:fren_app/controller/chat_controller.dart';
import 'package:fren_app/tabs/conversations_tab.dart';
import 'package:fren_app/tabs/discover_tab.dart';
import 'package:fren_app/tabs/profile_tab.dart';
import 'package:fren_app/widgets/notification_counter.dart';
import 'package:fren_app/widgets/svg_icon.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../widgets/float_frank.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatController chatController = Get.put(ChatController());
  /// Variables
  final _conversationsApi = ConversationsApi();
  final _notificationsApi = NotificationsApi();
  final _appNotifications = AppNotifications();

  int _selectedIndex = 0;
  late AppLocalizations _i18n;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  // in_app_purchase stream
  late StreamSubscription<List<PurchaseDetails>> _inAppPurchaseStream;

  /// Tab navigation
  Widget _showCurrentNavBar() {
    List<Widget> options = <Widget>[
      const DiscoverTab(),
      const ConversationsTab(),
      NotificationsScreen(),
      const ProfileTab()
    ];

    return options.elementAt(_selectedIndex);
  }

  /// Update selected tab
  void _onTappedNavBar(int index) {
    setState(() {
      _selectedIndex = index;
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

  ///
  /// Handle in-app purchases updates
  ///
  void _handlePurchaseUpdates() {
    // Listen purchase updates
    _inAppPurchaseStream =
        InAppPurchase.instance.purchaseStream.listen((purchases) async {
      // Loop incoming purchases
      for (var purchase in purchases) {
        // Control purchase status
        switch (purchase.status) {
          case PurchaseStatus.pending:
            // Handle this case.
            break;
          case PurchaseStatus.purchased:

            /// **** Deliver product to user **** ///
            ///
            /// Update User VIP Status to true
            UserModel().setUserVip();
            // Set Vip Subscription Id
            UserModel().setActiveVipId(purchase.productID);

            /// Update user verified status
            await UserModel().updateUserData(
                userId: UserModel().user.userId,
                data: {USER_IS_VERIFIED: true});

            // User first name
            final String userFirstname =
                UserModel().user.userFullname.split(' ')[0];

            /// Save notification in database for user
            _notificationsApi.onPurchaseNotification(
              nMessage: '${_i18n.translate("hello")} $userFirstname, '
                  '${_i18n.translate("your_vip_account_is_active")}\n '
                  '${_i18n.translate("thanks_for_buying")}',
            );

            if (purchase.pendingCompletePurchase) {
              /// Complete pending purchase
              InAppPurchase.instance.completePurchase(purchase);
              debugPrint('Success pending purchase completed!');
            }
            break;
          case PurchaseStatus.error:
            // Handle this case.
            debugPrint('purchase error-> ${purchase.error?.message}');
            break;
          case PurchaseStatus.restored:

            ///
            /// <--- Restore VIP Subscription --->
            ///
            UserModel().setUserVip();
            // Set Vip Subscription Id
            UserModel().setActiveVipId(purchase.productID);
            // Debug
            debugPrint('Active VIP SKU: ${purchase.productID}');
            // Check
            if (UserModel().showRestoreVipMsg) {
              // Show toast message
              Fluttertoast.showToast(
                msg: _i18n.translate('VIP_subscription_successfully_restored'),
                gravity: ToastGravity.BOTTOM,
                backgroundColor: APP_PRIMARY_COLOR,
                textColor: Colors.white,
              );
            }
            break;
          case PurchaseStatus.canceled:
            // Show canceled feedback
            Fluttertoast.showToast(
              msg:
                  _i18n.translate('you_canceled_the_purchase_please_try_again'),
              gravity: ToastGravity.BOTTOM,
              backgroundColor: APP_PRIMARY_COLOR,
              textColor: Colors.white,
            );
            break;
        }
      }
    });
  }

  Future<void> _handleNotificationClick(Map<String, dynamic>? data) async {
    /// Handle notification click
    await _appNotifications.onNotificationClick(
      context,
      nType: data?[N_TYPE] ?? '',
      nSenderId: data?[N_SENDER_ID] ?? '',
      nMessage: data?[N_MESSAGE] ?? '',
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


  @override
  void initState() {
    super.initState();
    /// Restore VIP Subscription
    AppHelper().restoreVipAccount();

    /// Init streams
    _getCurrentUserUpdates();
    // _handlePurchaseUpdates();
    _initFirebaseMessage();

    /// Request permission for IOS
    _requestPermissionForIOS();
  }

  @override
  void dispose() {
    super.dispose();
    // Close streams
    _userStream.drain();
    _inAppPurchaseStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/machi.png", height: 40),
            const SizedBox(width: 10),
          ],
        ),
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


            /// Discover new machi
            BottomNavigationBarItem(
                label: "Machi",
                icon: Icon(Iconsax.search_favorite,
                    color: _selectedIndex == 0
                        ? Theme.of(context).primaryColor
                        : null)),

            /// Conversations Tab
            // BottomNavigationBarItem(
            //     label: _i18n.translate("chat"),
            //     icon: _getConversationCounter(),),

            /// notification tab
            BottomNavigationBarItem(
                icon:  _getNotificationCounter(),
                label: _i18n.translate("notif")
            ),

            /// Profile Tab
            BottomNavigationBarItem(
              label: _i18n.translate("profile"),
              icon: Icon(Iconsax.user,
                    color: _selectedIndex == 3
                        ? Theme.of(context).primaryColor
                        : null),),
          ]),
      body: _showCurrentNavBar(),
          floatingActionButton: FloatingActionButton(
          onPressed: () async {

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    const BotChatScreen()
                ));
          },
          backgroundColor: Colors.white,
          child: const FrankImage(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  /// Count unread notifications
  Widget _getNotificationCounter() {
    // Set icon
    const icon = Icon(Iconsax.notification);

    /// Handle stream
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notificationsApi.getNotifications(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[N_READ] == false)
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
    final icon = Icon(Iconsax.message, color: _selectedIndex == 2 ? Theme.of(context).primaryColor : null);

    /// Handle stream
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _conversationsApi.getConversations(),
        builder: (context, snapshot) {
          // Check result
          if (!snapshot.hasData) {
            return icon;
          } else {
            /// Get total counter to alert user
            final total = snapshot.data!.docs
                .where((doc) => doc.data()[MESSAGE_READ] == false)
                .toList()
                .length;
            if (total == 0) return icon;
            return NotificationCounter(icon: icon, counter: total);
          }
        });
  }
}
