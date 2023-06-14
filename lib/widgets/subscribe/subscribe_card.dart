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
    } on PlatformException catch (e) {
      // Error fetching purchaser info
      Get.snackbar(
        _i18n.translate("Error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    double screenWidth = MediaQuery.of(context).size.width;

    // if (purchaserInfo.entitlements.all["your_entitlement_id"].isActive) {
    //   // user has access to "your_entitlement_id"
    // }

    if (!isUserSubscribed) {
      return Card(
          child: SizedBox(
              width: screenWidth,
              child: InkWell(
                  onTap: () {
                    _showSubscription();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Iconsax.buy_crypto),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _i18n.translate("subscription"),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  _i18n.translate(
                                      "become_a_subscription_member"),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            )
                          ])))));
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
