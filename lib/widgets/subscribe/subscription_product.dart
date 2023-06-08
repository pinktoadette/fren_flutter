import 'package:flutter/services.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class SubscriptionProduct extends StatefulWidget {
  const SubscriptionProduct({Key? key}) : super(key: key);

  @override
  _SubscriptionProductState createState() => _SubscriptionProductState();
}

class _SubscriptionProductState extends State<SubscriptionProduct> {
  bool isUserSubscribed = false;
  late AppLocalizations _i18n;
  String _selectedTier = "sub_weekly";

  List<Offering> offers = [];

  @override
  void initState() {
    super.initState();
    fetchOffers();
    isUserSubscribed = UserModel().user.isSubscribed;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

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
                style: const TextStyle(fontSize: 12),
              ),
            )
          ]),
        ),
        body: _showTiers());
  }

  Future fetchOffers() async {
    try {
      List<Offering> offerings = await PurchasesApi.fetchOffers();
      setState(() {
        offers = offerings;
        _selectedTier = offerings[0].availablePackages[1].identifier;
      });
    } on PlatformException catch (e) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("subscribe_no_offering_found"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  Widget _showTiers() {
    if (offers.isEmpty) {
      return const NoData(text: "Guess we are not selling today!");
    }
    return Column(
      children: [
        Text(offers[0].serverDescription),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: offers[0].availablePackages.map((e) {
              return _individualTier(e);
            }).toList()),
        const Spacer(),
        _showPricing(),
        ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 4,
            ),
            child: Text(_i18n.translate("subscribe_start_button"))),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }

  Widget _individualTier(Package info) {
    double screenWidth = MediaQuery.of(context).size.width;
    int numPackages = offers[0].availablePackages.length;
    return InkWell(
        onTap: () {
          setState(() {
            _selectedTier = info.identifier;
          });
        },
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _selectedTier == info.identifier
                        ? APP_ACCENT_COLOR
                        : Theme.of(context).colorScheme.primary,
                    width: _selectedTier == info.identifier ? 3 : 1,
                  ),
                ),
                width: (screenWidth / numPackages) - numPackages * 3.5,
                height: 200,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(info.storeProduct.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const Spacer(),
                    Text(info.storeProduct.priceString,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ))));
  }

  // ignore: unused_element
  Widget _showPricing() {
    int index = offers[0]
        .availablePackages
        .indexWhere((element) => element.identifier == _selectedTier);
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
                    Text(
                      _i18n.translate("subscribe_detail_plan_premium"),
                      style: Theme.of(context).textTheme.bodyMedium,
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
