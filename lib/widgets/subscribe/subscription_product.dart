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
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    isUserSubscribed = UserModel().user.isSubscribed;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: DefaultTabController(
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
              onTap: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
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
                child: Text(_i18n.translate("subscribe_pro")),
              )
            ]),
          ),
          body: TabBarView(
            children: [
              _showPricing(1),
              _showPricing(2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showPricing(int index) {
    Color color = index == 1 ? APP_ERROR : APP_SUCCESS;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.8,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: width * 0.8,
                            child: Flexible(
                                child: index == 1
                                    ? Text(
                                        _i18n.translate(
                                            "subscribe_detail_plan_free"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )
                                    : Text(
                                        _i18n.translate(
                                            "subscribe_detail_plan_premium"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )))
                      ],
                    ),
                    const SizedBox(height: 20),
                    _rowFeature(
                        APP_SUCCESS,
                        index,
                        _i18n.translate("subscribe_detail_unlimted_request") +
                            (index == 1 ? " of 5 Per Day" : "")),
                    _rowFeature(color, index,
                        _i18n.translate("subscribe_detail_image_genator")),
                    _rowFeature(color, index,
                        _i18n.translate("subscribe_detail_read_image")),
                    _rowFeature(color, index,
                        _i18n.translate("subscribe_detail_add_friends")),
                    _rowFeature(
                        color,
                        index,
                        _i18n.translate(
                            "subscribe_detail_access_additional_models"))
                  ],
                ),
              )))
        ],
      ),
    );
  }

  Widget _rowFeature(Color iconColor, int index, String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Iconsax.tick_circle,
            color: iconColor,
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
