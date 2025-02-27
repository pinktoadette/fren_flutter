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
import 'package:machi_app/widgets/ads/reward_ads.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:machi_app/dialogs/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionProduct extends StatefulWidget {
  const SubscriptionProduct({Key? key}) : super(key: key);

  @override
  State<SubscriptionProduct> createState() => _SubscriptionProductState();
}

class _SubscriptionProductState extends State<SubscriptionProduct> {
  bool isUserSubscribed = false;
  late AppLocalizations _i18n;
  late Package _selectedTier;
  bool isLoading = false;
  SubscribeController subscribeController = Get.find(tag: 'subscribe');

  Offering? offers;
  int qty = 0;
  List<Package> packages = [];
  late ProgressDialog _pr;

  @override
  void initState() {
    super.initState();
    subscribeController.getCredits();
    fetchOffers();
    isUserSubscribed = UserModel().user.isSubscribed;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          automaticallyImplyLeading: false,
          leadingWidth: 50,
          centerTitle: false,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
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
              ],
            ),
            RewardAds(
                text: "Earn", onAdStatus: (e) {}, titleOnly: true, width: 100)
          ]),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
            child: _showTiers(context)));
  }

  Future fetchOffers() async {
    if (!mounted) {
      return;
    }
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
    double itemHeight = 410;
    Color backgroundColor = Theme.of(context).colorScheme.background;

    if (offers == null) {
      return const Center(child: NoData(text: "OOPS, something went wrong!"));
    }
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    "AI IMAGE: Imaginfy",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    offers!.serverDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _i18n.translate("plans_include_gpt"),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 122, 122, 122),
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 5; i++)
                        RoundedImage(
                            width: size.width / 6 - 5,
                            height: size.width / 6 - 5,
                            icon: const Icon(Iconsax.gallery_slash),
                            isLocal: true,
                            photoUrl:
                                "assets/images/subscribe/image${i + 1}.png"),
                    ],
                  ),
                ],
              )),
          SizedBox(
              width: size.width,
              height: itemHeight,
              child: Swiper(
                  scrollDirection: Axis.vertical,
                  outer: true,
                  itemWidth: size.width * 0.9,
                  itemHeight: itemHeight,
                  fade: 0.8,
                  viewportFraction: 0.39,
                  scale: 0.7,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    String period = _formatPeriod(
                        package.storeProduct.subscriptionPeriod ?? '');
                    String qty = package.storeProduct.identifier
                        .replaceAll(RegExp(r'[^0-9]'), ''); // '23'
                    Color color = _selectedTier == package
                        ? Colors.black
                        : APP_INVERSE_PRIMARY_COLOR;
                    return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTier = package;
                          });
                        },
                        child: Card(
                            color: _selectedTier == package
                                ? period == "Week"
                                    ? APP_WARNING
                                    : APP_ACCENT_COLOR
                                : backgroundColor,
                            child: SizedBox(
                                width: size.width,
                                height: itemHeight,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                qty,
                                                style: TextStyle(
                                                    color: color,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                _i18n.translate("tokens"),
                                                style: TextStyle(
                                                    color: color,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (qty == SELL_10_UNITS ||
                                                    qty == SELL_300_UNITS)
                                                  Badge(
                                                    label: Text(
                                                      _i18n.translate(
                                                          "plans_${qty}_subtitle"),
                                                      style: TextStyle(
                                                          color:
                                                              backgroundColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                Text(" ${period}ly",
                                                    style: TextStyle(
                                                        color: color,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 10,
                                                )
                                              ],
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                text: package
                                                    .storeProduct.priceString,
                                                style: TextStyle(
                                                    color: color,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        ' / ${period.toLowerCase()}',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: color,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            SizedBox(
                                                width: size.width * 0.5,
                                                child: Text(
                                                  "Get ${period.toLowerCase()}ly subscription to $qty images",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: color),
                                                ))
                                          ],
                                        ),
                                      )
                                    ]))));
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
          const SizedBox(height: 10),
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
                  ))),
          const SizedBox(height: 30),
        ]));
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
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final purchaseApi = PurchasesApi();
    String info = await AppHelper().getRevenueCat();
    String qty = _selectedTier.identifier.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      _pr.show(_i18n.translate("processing"));

      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_selectedTier);
      if (purchaserInfo.entitlements.all[info]!.isActive) {
        _pr.hide();

        try {
          _pr.show(_i18n.translate("adding_credits"));
          await Future.delayed(const Duration(seconds: 1));

          /// Need use retries and delay since revenue has race conditions
          Map<String, dynamic> response = await purchaseApi.purchaseCredits(3);

          /// this is to double check backend and revenue cat are aligned in number of credits
          int responseQty = response["subscribeTotal"] ?? 0;

          if (responseQty == int.parse(qty)) {
            subscribeController.addCredits(responseQty);
            Get.snackbar(_i18n.translate("success"),
                _i18n.translate("subscribed_successfully"),
                snackPosition: SnackPosition.TOP,
                backgroundColor: APP_SUCCESS,
                colorText: Colors.black);
          } else {
            Get.snackbar(_i18n.translate("error"),
                "Unable to credit. Please contact us!",
                snackPosition: SnackPosition.TOP,
                backgroundColor: APP_ERROR,
                colorText: Colors.black);
          }
        } catch (err, s) {
          Get.snackbar(_i18n.translate("error"),
              _i18n.translate("an_error_has_occurred"),
              snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
          await FirebaseCrashlytics.instance.recordError(err, s,
              reason: 'Unable to save purchase offers: ${err.toString()}',
              fatal: true);
        } finally {
          _pr.hide();
          Get.back(result: true);
        }
      }
    } on PlatformException catch (err, s) {
      var errorCode = PurchasesErrorHelper.getErrorCode(err);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        await FirebaseCrashlytics.instance.recordError(err, s,
            reason: 'Unable to purchase offers: ${err.toString()}',
            fatal: false);
        Get.snackbar(_i18n.translate("error"),
            "Payment vendor: ${err.message.toString()}",
            snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
      }
    } finally {
      await subscribeController.getCredits();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      _pr.hide();
    }
  }
}
