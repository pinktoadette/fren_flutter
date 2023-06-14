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
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20), child: _showTiers()));
  }

  Future fetchOffers() async {
    try {
      List<Offering> offerings = await PurchasesApi.fetchOffers();
      setState(() {
        offers = offerings;
        _selectedTier = offerings[0].availablePackages[1];
      });
    } on PlatformException catch (_) {
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
        Text(
          offers[0].serverDescription,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          _i18n.translate("subscribe_whats_different"),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: offers[0].availablePackages.map((e) {
              return _individualTier(e);
            }).toList()),
        _showPricing(),
        ElevatedButton(
            onPressed: () {
              _makePurchase();
            },
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
    double padding = 5;
    return InkWell(
        onTap: () {
          setState(() {
            _selectedTier = info;
          });
        },
        child: Padding(
            padding: EdgeInsets.all(padding),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _selectedTier == info
                        ? APP_ACCENT_COLOR
                        : Theme.of(context).colorScheme.primary,
                    width: _selectedTier == info ? 3 : 1,
                  ),
                ),
                width:
                    (screenWidth / numPackages) - numPackages - (padding * 6),
                height: 250,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(info.storeProduct.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
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

  Widget _showPricing() {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _i18n.translate("subscribe_detail_plan_premium"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            _selectedTier.storeProduct.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          if (!_selectedTier.storeProduct.identifier
              .contains(SUB_TOKEN_IDENTIFIER))
            ..._subFeatures(),
          if (_selectedTier.storeProduct.identifier
              .contains(SUB_TOKEN_IDENTIFIER))
            ..._tokenFeatures()
        ],
      ),
    ));
  }

  List<Widget> _tokenFeatures() {
    return [
      _rowGenerator(
          const Icon(
            Iconsax.tick_square,
            color: APP_SUCCESS,
          ),
          _i18n.translate("subscribe_tokens_description")),
      _rowGenerator(const Icon(Iconsax.tick_square, color: APP_SUCCESS),
          _i18n.translate("subscribe_tokens_info")),
      _rowGenerator(const Icon(Iconsax.tick_square, color: APP_SUCCESS),
          _i18n.translate("subscribe_tokens_image")),
    ];
  }

  List<Widget> _subFeatures() {
    bool hasLimit =
        !_selectedTier.storeProduct.identifier.contains(SUB_TOKEN_IDENTIFIER);
    return [
      _rowGenerator(const Icon(Iconsax.tick_circle, color: APP_SUCCESS),
          _i18n.translate("subscribe_detail_unlimted_request")),
      _rowGenerator(
          const Icon(Iconsax.tick_circle, color: APP_WARNING),
          _i18n.translate("subscribe_detail_image_genator") +
              (hasLimit == true ? " of 2 Per Week" : "")),
      _rowGenerator(
          const Icon(Iconsax.tick_circle, color: APP_WARNING),
          _i18n.translate("subscribe_detail_read_image") +
              (hasLimit == true ? " of 2 Per Week" : "")),
    ];
  }

  Widget _rowGenerator(Icon icon, String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          icon,
          const SizedBox(
            width: 10,
          ),
          Flexible(child: Text(text))
        ],
      ),
    );
  }

  void _makePurchase() async {
    final _purchaseApi = PurchasesApi();
    try {
      CustomerInfo purchaserInfo =
          await Purchases.purchasePackage(_selectedTier);
      if (purchaserInfo.entitlements.all["Premium"]!.isActive) {
        await _purchaseApi.saveUserPurchase(purchaserInfo);
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        Get.snackbar(
            _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: APP_ERROR);
      }
    }
  }
}
