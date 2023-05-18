import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/bot_api.dart';
import 'package:machi_app/api/notifications_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/notifications_screen.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/discover_card.dart';
import 'package:machi_app/widgets/common/frosted_app_bar.dart';
import 'package:machi_app/widgets/notification_counter.dart';
import 'package:machi_app/widgets/search_user.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';
import 'package:machi_app/widgets/timeline/timeline_widget.dart';
import 'package:machi_app/widgets/tips/tips_widget.dart';
import 'package:get/get.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  _ActivityTabState createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  final TimelineController timelineController = Get.find(tag: 'timeline');
  final _notificationsApi = NotificationsApi();

  final _botApi = BotApi();
  List _listFeatures = [];
  int _currentStep = 0;
  bool _visible = true;
  bool _isInitiatedFrank = false;

  Future<void> _fetchInitialFrankie() async {
    List steps = await _botApi.getInitialFrankie();
    setState(() => _listFeatures = steps);
  }

  @override
  void initState() {
    super.initState();
    User user = UserModel().user;
    if (user.isFrankInitiated == false) {
      _fetchInitialFrankie();
    }
    setState(() {
      _isInitiatedFrank = user.isFrankInitiated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitiatedFrank == true) {
      return Scaffold(
          body: CustomScrollView(slivers: [
        FrostedAppBar(
            title: const AppLogo(),
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: _getNotificationCounter(),
                          onPressed: () async {
                            // Go to Notifications Screen
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NotificationsScreen()));
                          }),
                    ],
                  )),
            ],
            showLeading: true),
        SliverToBoxAdapter(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SearchBarWidget(),
            const SubscriptionCard(),
            TipWidget(),
            const TimelineWidget(),
            const SizedBox(
              height: 100,
            )
          ],
        ))
      ]));
    }
    // AppLogo()
    return Scaffold(
        body: CustomScrollView(slivers: [
      FrostedAppBar(
          title: const AppLogo(),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                        icon: _getNotificationCounter(),
                        onPressed: () async {
                          // Go to Notifications Screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NotificationsScreen()));
                        }),
                  ],
                )),
          ],
          showLeading: true),
      Column(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ActivityWidget()
                if (_currentStep < _listFeatures.length) _onCardClick(),
              ],
            ),
          ),
          const Spacer(),
        ],
      )
    ]));
  }

  Widget _onCardClick() {
    if ((_currentStep == _listFeatures.length - 1) & (_visible == false)) {
      /// update user isFrankieInitaited false
      _updateUser();
    }
    return NotificationListener<ButtonChanged>(
        child: AnimatedOpacity(
          // If the widget is visible, animate to 0.0 (invisible).
          // If the widget is hidden, animate to 1.0 (fully visible).
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          // The green box must be a child of the AnimatedOpacity widget.
          child: DiscoverCard(
            title: _listFeatures[_currentStep]['title'],
            subtitle: _listFeatures[_currentStep]['subtitle'],
            btnText: _listFeatures[_currentStep]['btn_text'],
          ),
        ),
        onNotification: (n) {
          if (_currentStep <= _listFeatures.length) {
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _visible = false;
              });
            });

            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _currentStep = _currentStep + 1;
                _visible = true;
              });
            });
          } else {
            setState(() {
              _currentStep = _currentStep + 1;
              _visible = false;
            });
          }
          return true;
        });
  }

  void _updateUser() async {
    Map<String, bool> data = {USER_INITIATED_FRANK: true};
    await UserModel()
        .updateUserData(userId: UserModel().user.userId, data: data);
    setState(() {
      _isInitiatedFrank = true;
    });
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
            return NotificationCounter(
              icon: icon,
              counter: total,
              iconPadding: 10,
            );
          }
        });
  }
}
