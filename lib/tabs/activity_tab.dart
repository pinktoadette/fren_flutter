import 'package:flutter/material.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';
import 'package:machi_app/widgets/timeline/timeline_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/tips/tips_widget.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  _ActivityTabState createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  bool _isInitiatedFrank = false;
  SubscribeController subscriptionController = Get.find(tag: 'subscribe');
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
        body: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 50,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppLogo(),
            SubscribeTokenCounter(),
          ],
        ),
        if (subscriptionController.customer.allPurchaseDates.isEmpty)
          const SubscriptionCard(),
        if (_isInitiatedFrank == false) const TipWidget(),
        const TimelineWidget(),
      ],
    ))

        //     CustomScrollView(controller: scrollController, slivers: [
        //   FrostedAppBar(
        //       title: const AppLogo(),
        //       actions: [
        //         if (_isInitiatedFrank == false)
        //           Padding(
        //               padding: const EdgeInsets.only(top: 8),
        //               child: IconButton(
        //                   onPressed: () {
        //                     Get.to(() => const HowToMachi());
        //                   },
        //                   icon: const Icon(
        //                     Iconsax.info_circle,
        //                     color: APP_ACCENT_COLOR,
        //                   ))),
        //         const SubscribeTokenCounter(),
        //         Padding(
        //             padding: const EdgeInsets.only(right: 10),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.start,
        //               crossAxisAlignment: CrossAxisAlignment.end,
        //               children: [
        //                 IconButton(
        //                     icon: _getNotificationCounter(),
        //                     onPressed: () async {
        //                       // Go to Notifications Screen
        //                       Navigator.of(context).push(MaterialPageRoute(
        //                           builder: (context) => NotificationsScreen()));
        //                     }),
        //               ],
        //             )),
        //       ],
        //       showLeading: true),
        //   SliverToBoxAdapter(
        //       child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       if (subscriptionController.customer.allPurchaseDates.isEmpty)
        //         const SubscriptionCard(),
        //       if (_isInitiatedFrank == false) const TipWidget(),
        //     ],
        //   )),
        //   const TimelineWidget(),
        // ])

        );
  }
}

/// Count unread notifications
// Widget _getNotificationCounter() {
//   final _notificationsApi = NotificationsApi();

//   const icon = Icon(Iconsax.notification);
//   return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: _notificationsApi.getNotifications(),
//       builder: (context, snapshot) {
//         // Check result
//         if (!snapshot.hasData) {
//           return icon;
//         } else {
//           /// Get total counter to alert user
//           final total = snapshot.data!.docs
//               .where((doc) => doc.data()[NOTIF_READ] == false)
//               .toList()
//               .length;
//           if (total == 0) return icon;
//           return NotificationCounter(
//             icon: icon,
//             counter: total,
//             iconPadding: 10,
//           );
//         }
//       });
// }
