import 'package:card_swiper/card_swiper.dart';
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
                style: const TextStyle(fontSize: 12),
              ),
            )
          ]),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20), child: _showTiers(context)));
  }

  Future fetchOffers() async {
    try {
      List<Offering> offerings = await PurchasesApi.fetchOffers();

      setState(() {
        offers = offerings[0];
        packages = offerings[0].availablePackages;
        _selectedTier = offerings[0].availablePackages[0];
      });
    } on PlatformException catch (e) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("subscribe_no_offering_found"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
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
                            const TextStyle(color: Colors.white, fontSize: 20),
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
          const SizedBox(
            height: 20,
          ),
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
                    List<String> id =
                        package.storeProduct.identifier.split(":");
                    return Card(
                        elevation: 5,
                        shadowColor: Colors.black,
                        color: _selectedTier == package
                            ? APP_ACCENT_COLOR
                            : APP_ACCENT_COLOR.withAlpha(250),
                        child: Container(
                            padding: const EdgeInsets.all(30),
                            width: size.width,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(" ${period}ly",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  if (id[1] == UPSELL_AFFORDABLE ||
                                      id[1] == UPSELL_BULK)
                                    Badge(
                                      label: Text(
                                        _i18n.translate(
                                            "plans_${id[1]}_subtitle"),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "${package.storeProduct.priceString} per $period",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        _i18n.translate("plans_${id[1]}"),
                                        style: const TextStyle(
                                            fontSize: 24, color: Colors.black),
                                      )),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        _i18n.translate("plans_${id[1]}_unit"),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                      )),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  Text(_i18n.translate("plans_${id[1]}_des"),
                                      style:
                                          const TextStyle(color: Colors.black)),
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
                  }
                  // control: const SwiperControl(),
                  )),
          const SizedBox(
            height: 40,
          ),
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
        await _purchaseApi.saveUserPurchase(purchaserInfo);
      }
      Navigator.of(context).pop();

      Get.snackbar(_i18n.translate("success"),
          _i18n.translate("subscribed_successfully"),
          snackPosition: SnackPosition.TOP, backgroundColor: APP_SUCCESS);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        Get.snackbar(
            _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
            snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
      }
    }
  }
}
