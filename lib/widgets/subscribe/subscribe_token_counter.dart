import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/widgets/subscribe/subscribe_purchase_details.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';

class SubscribeTokenCounter extends StatefulWidget {
  const SubscribeTokenCounter({Key? key}) : super(key: key);

  @override
  _SubscribeTokenCounterState createState() => _SubscribeTokenCounterState();
}

class _SubscribeTokenCounterState extends State<SubscribeTokenCounter> {
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {
          _showSubscription(context);
        },
        icon: const Icon(Iconsax.coin),
        label: Obx(() => Text(subscribeController.credits.value.toString())));
  }

  void _showSubscription(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => Obx(() => FractionallySizedBox(
            heightFactor: subscribeController.credits.value > 0 ? 0.5 : 0.98,
            child: subscribeController.credits.value > 0
                ? const SubscribePurchaseDetails()
                : const SubscriptionProduct())));
  }
}
