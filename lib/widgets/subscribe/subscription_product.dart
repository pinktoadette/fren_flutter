import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionProduct extends StatefulWidget {
  const SubscriptionProduct({Key? key}) : super(key: key);

  @override
  _SubscriptionProductState createState() => _SubscriptionProductState();
}

class _SubscriptionProductState extends State<SubscriptionProduct> {
  bool isUserSubscribed = false;
  late AppLocalizations _i18n;
  late Package _selectedTier;

  Offering? offers;
  List<Package> packages = [];

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
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            )
          ]),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
            child: _showTiers(context)));
  }

  Future fetchOffers() async {
    try {
      List<Offering> offerings = await PurchasesApi.fetchOffers();

      setState(() {
        offers = offerings[0];
        packages = offerings[0].availablePackages;
        _selectedTier = offerings[0].availablePackages[0];
      });
    } on PlatformException catch (err, s) {
      debugPrint(err.message);
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("subscribe_no_offering_found"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );

      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot fetch offers: ${err.message}', fatal: true);
    }
  }

  Widget _showTiers(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (offers == null) {
      return const NoData(text: "Guess we are not selling today!");
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
              color: Colors.black,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        offers!.metadata['main_title'] as String,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        offers!.serverDescription,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        _i18n.translate("plans_include_gpt"),
                        style: const TextStyle(
                            color: Color.fromARGB(255, 122, 122, 122),
                            fontSize: 12),
                      ),
                    ],
                  ))),
          SizedBox(
              width: size.width,
              height: size.width,
              child: Swiper(
                  outer: true,
                  itemWidth: size.width * 0.7,
                  itemHeight: size.width,
                  fade: 0.8,
                  viewportFraction: 0.7,
                  scale: 0.8,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    String period = _formatPeriod(
                        package.storeProduct.subscriptionPeriod ?? '');
                    String id = Platform.isAndroid
                        ? package.storeProduct.identifier.split(":")[1]
                        : package.storeProduct.identifier;
                    return Card(
                        elevation: 5,
                        shadowColor: Colors.black,
                        color: _selectedTier == package
                            ? APP_ACCENT_COLOR
                            : APP_ACCENT_COLOR.withAlpha(250),
                        child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/subscribe/image${index + 1}.png"),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                colorFilter: ColorFilter.mode(
                                    const Color.fromARGB(255, 47, 47, 47)
                                        .withOpacity(0.2),
                                    BlendMode.colorBurn),
                              ),
                            ),
                            width: size.width,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(0),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black45,
                                          Colors.black
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0, 0.2, 1],
                                      ),
                                    ),
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      children: [
                                        Text(" ${period}ly",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        if (id == UPSELL_AFFORDABLE ||
                                            id == UPSELL_BULK)
                                          Badge(
                                            label: Text(
                                              _i18n.translate(
                                                  "plans_${id}_subtitle"),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                "${package.storeProduct.priceString} per $period",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 25,
                                                right: 25,
                                                top: 10,
                                                bottom: 10),
                                            child: Text(
                                              package.storeProduct.description,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              _i18n.translate(
                                                  "plans_${id}_unit"),
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            )),
                                      ],
                                    ),
                                  )
                                ])));
                  },
                  indicatorLayout: PageIndicatorLayout.COLOR,
                  autoplay: false,
                  itemCount: packages.length,
                  pagination: const SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                          size: 8,
                          space: 5,
                          activeColor: APP_ACCENT_COLOR,
                          color: Colors.grey)),
                  onIndexChanged: (value) {
                    setState(() {
                      _selectedTier = packages[value];
                    });
                  })),
          const SizedBox(height: 30),
          SizedBox(
              width: size.width * 0.4,
              child: ElevatedButton(
                  onPressed: () {
                    _makePurchase();
                  },
                  child: Text(
                    _i18n.translate("SUBSCRIBE"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )))
        ]);
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'P1W':
        return 'Week';
      case 'P1M':
        return 'Month';
      case 'P1Y':
        return 'Yearly';
      default:
        return '';
    }
  }

  void _makePurchase() async {
    final _purchaseApi = PurchasesApi();
    String info = await AppHelper().getRevenueCat();
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_selectedTier);
      if (purchaserInfo.entitlements.all[info]!.isActive) {
        await _purchaseApi.purchaseCredits();
        await _purchaseApi.getCredits();
      }

      Get.snackbar(_i18n.translate("success"),
          _i18n.translate("subscribed_successfully"),
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS);
      Navigator.of(context).pop();
    } on PlatformException catch (e, s) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        Get.snackbar(
            _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
            snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
        await FirebaseCrashlytics.instance.recordError(e, s,
            reason: 'Unable to purchase offers: ${e.message}', fatal: true);
      }
    }
  }
}
