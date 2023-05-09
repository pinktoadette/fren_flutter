import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';
import 'package:iconsax/iconsax.dart';

class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({Key? key}) : super(key: key);

  @override
  _SubscriptionCardState createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool isUserSubscribed = false;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    isUserSubscribed = UserModel().user.isSubscribed;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    double screenWidth = MediaQuery.of(context).size.width;

    if (!isUserSubscribed) {
      return Card(
          color: APP_ACCENT_COLOR,
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
                              child: Icon(Iconsax.element_plus),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _i18n.translate("subscription"),
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
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
            heightFactor: 0.9, child: SubscriptionProduct()));
  }
}
