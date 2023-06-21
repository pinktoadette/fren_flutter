import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/notifications_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/notifications_screen.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/common/frosted_app_bar.dart';
import 'package:machi_app/widgets/notification_counter.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';
import 'package:machi_app/widgets/timeline/timeline_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/tips/machi_how_to.dart';
import 'package:machi_app/widgets/tips/tips_widget.dart';

class ActivityTab extends StatefulWidget {
  // const ActivityTab({super.key});

  const ActivityTab({Key? key}) : super(key: key);

  @override
  _ActivityTabState createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  bool _isInitiatedFrank = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    User user = UserModel().user;
    setState(() {
      _isInitiatedFrank = user.isFrankInitiated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(controller: scrollController, slivers: [
      FrostedAppBar(
          title: const AppLogo(),
          actions: [
            if (_isInitiatedFrank == false)
              IconButton(
                  onPressed: () {
                    Get.to(() => const HowToMachi());
                  },
                  icon: const Icon(Iconsax.info_circle)),
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
          // SearchBarWidget(),
          const SubscriptionCard(),
          if (_isInitiatedFrank == false) const TipWidget(),
        ],
      )),
      const TimelineWidget(),
    ]));
  }
}

/// Count unread notifications
Widget _getNotificationCounter() {
  final _notificationsApi = NotificationsApi();

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
