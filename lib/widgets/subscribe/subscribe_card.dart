import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({Key? key}) : super(key: key);

  @override
  _SubscriptionCardState createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool isUserSubscribed = false;
  late AppLocalizations _i18n;
  CustomerInfo? customer;
  @override
  void initState() {
    super.initState();
    _fetchSubscription();
    isUserSubscribed = UserModel().user.isSubscribed;
  }

  void _fetchSubscription() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      setState(() {
        customer = customerInfo;
      });
    } on PlatformException catch (err, s) {
      // Error fetching purchaser info
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: "Cannot fetch customer ${err.message}", fatal: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    double screenWidth = MediaQuery.of(context).size.width;

    if (!isUserSubscribed) {
      return Container(
          color: APP_ACCENT_COLOR,
          width: screenWidth,
          child: InkWell(
              onTap: () {
                _showSubscription();
              },
              child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Iconsax.buy_crypto,
                            color: Colors.black,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _i18n.translate("subscription"),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                                _i18n.translate("become_a_subscription_member"),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14)),
                          ],
                        )
                      ]))));
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showSubscription() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const FractionallySizedBox(
            heightFactor: 0.97, child: SubscriptionProduct()));
  }
}
