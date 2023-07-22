import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_helper.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
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
  bool isLoading = false;
  SubscribeController subscribeController = Get.find(tag: 'subscribe');

  Offering? offers;
  List<Package> packages = [];

  @override
  void initState() {
    super.initState();
    subscribeController.getCredits();
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
      return const Center(
          child: NoData(text: "Guess we are not selling today!"));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
              borderOnForeground: false,
              shadowColor: Colors.black,
              color: Colors.black,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Imaginfy",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        offers!.serverDescription,
                        style: const TextStyle(color: Colors.white),
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
              height: 300,
              child: Swiper(
                  scrollDirection: Axis.vertical,
                  outer: true,
                  itemWidth: size.width * 0.9,
                  itemHeight: 300,
                  fade: 0.8,
                  viewportFraction: 0.39,
                  scale: 0.7,
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
                            : APP_ACCENT_COLOR.withAlpha(100),
                        child: Container(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.all(0),
                            width: size.width * 0.65,
                            height: size.width * 0.3,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 200,
                                    child: Image.asset(
                                        "assets/images/subscribe/image${index + 1}.png"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(" ${period}ly",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        if (id == UPSELL_AFFORDABLE ||
                                            id == UPSELL_BULK)
                                          Badge(
                                            label: Text(
                                              _i18n.translate(
                                                  "plans_${id}_subtitle"),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                            "${package.storeProduct.priceString} per $period",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))
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
              child: ElevatedButton.icon(
                  onPressed: () {
                    _makePurchase();
                  },
                  icon: isLoading == true
                      ? loadingButton(size: 16, color: Colors.black)
                      : const SizedBox.shrink(),
                  label: Text(
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
    setState(() {
      isLoading = true;
    });
    final _purchaseApi = PurchasesApi();
    String info = await AppHelper().getRevenueCat();
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_selectedTier);
      if (purchaserInfo.entitlements.all[info]!.isActive) {
        try {
          await _purchaseApi.purchaseCredits();
          await _purchaseApi.getCredits();
        } catch (err, s) {
          Get.snackbar(_i18n.translate("error"),
              _i18n.translate("an_error_has_occurred"),
              snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
          await FirebaseCrashlytics.instance.recordError(err, s,
              reason: 'Unable to save purchase offers: ${err.toString()}',
              fatal: true);
        }
      }

      Get.snackbar(_i18n.translate("success"),
          _i18n.translate("subscribed_successfully"),
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS);
      Navigator.of(context).pop();
    } on PlatformException catch (err, s) {
      var errorCode = PurchasesErrorHelper.getErrorCode(err);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        await FirebaseCrashlytics.instance.recordError(err, s,
            reason: 'Unable to purchase offers: ${err.toString()}',
            fatal: true);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
