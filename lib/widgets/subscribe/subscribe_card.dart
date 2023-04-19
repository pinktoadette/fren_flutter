import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/subscribe/subscription.dart';
import 'package:fren_app/widgets/subscribe/subscription_product.dart';
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
          child: SizedBox(
              width: screenWidth,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _i18n.translate("subscription"),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(_i18n
                                .translate("become_a_subscription_member")),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  _showSubscription();
                                },
                                child: Text(_i18n.translate("SUBSCRIBE")))
                          ],
                        ),
                      ]))));
    } else {
      return const SizedBox.shrink();
    }
  }

  void _showSubscription() {
    double height = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: 1,
                minChildSize: 0.75,
                builder: (context, scrollController) => SingleChildScrollView(
                      controller: scrollController,
                      child: SizedBox(
                        height: height,
                        child: const SubscriptionProduct(),
                      ),
                    ))));
  }
}
