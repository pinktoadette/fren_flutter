import 'package:flutter/material.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/widgets/ads/interstitial_ads.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';
import 'package:machi_app/widgets/timeline/timeline_widget.dart';
import 'package:get/get.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  _ActivityTabState createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  SubscribeController subscriptionController = Get.find(tag: 'subscribe');

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "machi",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          automaticallyImplyLeading: false,
          actions: const [SubscribeTokenCounter()],
        ),
        body: Obx(() => SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subscriptionController.customer == null
                    ? const SizedBox.shrink()
                    : subscriptionController.customer!.allPurchaseDates.isEmpty
                        ? const SubscriptionCard()
                        : const SizedBox.shrink(),
                const TimelineWidget(),
              ],
            ))));
  }
}
