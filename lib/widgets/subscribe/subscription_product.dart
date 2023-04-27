import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SubscriptionProduct extends StatefulWidget {
  const SubscriptionProduct({Key? key}) : super(key: key);

  @override
  _SubscriptionProductState createState() => _SubscriptionProductState();
}

class _SubscriptionProductState extends State<SubscriptionProduct> {
  bool isUserSubscribed = false;
  late AppLocalizations _i18n;
  int _selectedTier = 2;
  @override
  void initState() {
    super.initState();
    isUserSubscribed = UserModel().user.isSubscribed;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return MaterialApp(
      home: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            bottom: TabBar(
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              dividerColor: APP_ACCENT_COLOR,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              tabs: [
                Tab(text: _i18n.translate("subscribe_free")),
                Tab(text: _i18n.translate("subscribe_premium")),
              ],
            ),
            title: Row(children: [
              Image.asset(
                "assets/images/machi.png",
                width: 100,
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                decoration: const BoxDecoration(
                    color: APP_ACCENT_COLOR,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: const EdgeInsets.all(5),
                child: Text(
                  _i18n.translate("subscribe_pro"),
                  style: const TextStyle(fontSize: 12),
                ),
              )
            ]),
          ),
          body: TabBarView(children: [
            _showPricing(1),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [_showPricing(2), _showTiers()],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _showTiers() {
    var tiers = [
      {
        "id": 1,
        "tier": "1 \nMonth",
        "price_week": "\$3.45 per week",
        "price": "\$14.99 per\n Month"
      },
      {
        "id": 2,
        "tier": "1 \nWeek",
        "price_week": "\$7.99 per week",
        "price": "\$7.99 per\n Week"
      },
      {
        "id": 3,
        "tier": "12 \nMonth",
        "price_week": "\$0.96 per week",
        "price": "\$49.99 per\n Year"
      }
    ];

    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: tiers.map((e) {
              return _individualTier(e);
            }).toList()),
        ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 4,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(_i18n.translate("subscribe_start_button")))
      ],
    );
  }

  Widget _individualTier(dynamic info) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
        onTap: () {
          setState(() {
            _selectedTier = info["id"];
          });
        },
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _selectedTier == info["id"]
                        ? APP_ACCENT_COLOR
                        : Theme.of(context).colorScheme.primary,
                    width: _selectedTier == info["id"] ? 3 : 1,
                  ),
                ),
                width: (screenWidth / 3) - 30,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(info["tier"],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    Text(info["price_week"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10)),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(info["price"],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                  ],
                ))));
  }

  Widget _showPricing(int index) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Icon icon = index == 1
        ? const Icon(Iconsax.close_circle)
        : const Icon(Iconsax.tick_circle);
    return SizedBox(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                            child: index == 1
                                ? Text(
                                    _i18n.translate(
                                        "subscribe_detail_plan_free"),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  )
                                : Text(
                                    _i18n.translate(
                                        "subscribe_detail_plan_premium"),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ))
                      ],
                    ),
                    const SizedBox(height: 20),
                    _rowFeature(
                        const Icon(Iconsax.tick_circle),
                        index,
                        _i18n.translate("subscribe_detail_unlimted_request") +
                            (index == 1 ? " of 5 Per Day" : "")),
                    _rowFeature(icon, index,
                        _i18n.translate("subscribe_detail_image_genator")),
                    _rowFeature(icon, index,
                        _i18n.translate("subscribe_detail_read_image")),
                    _rowFeature(icon, index,
                        _i18n.translate("subscribe_detail_add_friends")),
                    _rowFeature(
                        icon,
                        index,
                        _i18n.translate(
                            "subscribe_detail_access_additional_models")),
                    _rowFeature(
                        icon,
                        index,
                        _i18n
                            .translate("subscribe_get_notification_from_machi"))
                  ],
                ),
              )))
        ],
      ),
    );
  }

  Widget _rowFeature(Icon icon, int index, String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            icon.icon,
            color: icon.icon == Iconsax.tick_circle ? APP_SUCCESS : APP_ERROR,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(text)
        ],
      ),
    );
  }
}
