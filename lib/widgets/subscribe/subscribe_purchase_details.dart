import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

class SubscribePurchaseDetails extends StatefulWidget {
  const SubscribePurchaseDetails({Key? key}) : super(key: key);

  @override
  _SubscribePurchaseDetailsState createState() =>
      _SubscribePurchaseDetailsState();
}

class _SubscribePurchaseDetailsState extends State<SubscribePurchaseDetails> {
  final SubscribeController subscribeController = Get.find(tag: 'subscribe');
  late CustomerInfo customer;
  String activeSubscription = '';
  String activeExpiredDate = '';
  @override
  void initState() {
    super.initState();
    initializeCustomerData();
  }

  void initializeCustomerData() {
    final customer = subscribeController.customer;

    if (customer != null && mounted) {
      setState(() {
        this.customer = customer;

        if (customer.activeSubscriptions.isNotEmpty) {
          activeSubscription = customer.activeSubscriptions[0];
          final activeExpiredDateRaw =
              customer.allExpirationDates[activeSubscription];
          if (activeExpiredDateRaw != null) {
            activeExpiredDate = formatDate(activeExpiredDateRaw);
          }
        }
      });
    }
  }

  String formatDate(String date) {
    final dateTime = DateTime.parse(date).toLocal();
    return dateTime.toString().substring(0, 10);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          automaticallyImplyLeading: false,
          title: Row(children: [
            const AppLogo(),
            Container(
              margin: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                  color: APP_ACCENT_COLOR,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: const EdgeInsets.all(5),
              child: Text(
                _i18n.translate("subscribe_pro"),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            )
          ]),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _i18n.translate("subscribed_credits"),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                  "${_i18n.translate("subscribed_plan")} on $activeSubscription"),

              Obx(() => RichText(
                      text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              "${subscribeController.credits.value.toString()} ",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              _i18n.translate("subscribed_credits_remaining")),
                    ],
                  ))),
              const SizedBox(
                height: 10,
              ),
              Text(
                  "${_i18n.translate("subscribed_expires_on")} $activeExpiredDate"),
              const SizedBox(
                height: 80,
              ),
              // ElevatedButton(
              //     onPressed: () {},
              //     child: Text(_i18n.translate("subscribed_manage_plan"))),
              const SizedBox(
                height: 40,
              ),
              Text(_i18n.translate("subscribed_credits_expired_footnote"),
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
        ));
  }
}
