import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/ad_helper.dart';
import 'package:machi_app/widgets/button/loading_button.dart'; // Make sure to import your AdManager with interstitialAdUnitId defined

class RewardAds extends StatefulWidget {
  final String text;
  final bool titleOnly;
  final double? width;
  final Function(dynamic data) onAdStatus;
  const RewardAds(
      {Key? key,
      required this.text,
      required this.onAdStatus,
      this.titleOnly = false,
      this.width})
      : super(key: key);

  @override
  State<RewardAds> createState() => _RewardAdsState();
}

class _RewardAdsState extends State<RewardAds> {
  SubscribeController subscribeController = Get.find(tag: 'subscribe');

  RewardedAd? _ad;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  int _numRewardedInterstitialLoadAttempts = 0;
  static int maxFailedLoadAttempts = 3;
  late AppLocalizations _i18n;
  final _purchaseApi = PurchasesApi();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ad?.dispose();
    _numRewardedInterstitialLoadAttempts = 0;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  void _loadAds() {
    if (!mounted) {
      return;
    }
    RewardedAd.load(
        adUnitId: AdManager.rewardAds,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            setState(() {
              _ad = ad;
              _isAdLoaded = true;
            });
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {
                  _isLoading = false;
                },
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});
            if (_ad != null) {
              _showRewardAd();
            }

            debugPrint(
                '================================================================== $ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _ad = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Rewarded Ad failed to load: $error');
            _ad = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              Future.delayed(const Duration(seconds: 1), () {
                _loadAds();
              });
            } else if (_numRewardedInterstitialLoadAttempts ==
                maxFailedLoadAttempts) {
              String message = error.message;
              if (error.code == 3) {
                message = _i18n.translate("watch_ads_limit");
              }
              setState(() {
                _isLoading = false;
              });
              Get.snackbar(_i18n.translate("error"), message,
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: APP_ERROR,
                  colorText: Colors.black);
            }
          },
        ));
  }

  void _showRewardAd() {
    if (_isAdLoaded && _ad != null) {
      _isAdLoaded = false;

      _ad!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
        // Reward the user for watching an ad.
        debugPrint(
            "======================= reward ${rewardItem.amount.toString()}");
        subscribeController.updateRewards(rewardItem.amount.toInt());
        widget.onAdStatus(rewardItem.amount);
        await _purchaseApi.getRewards();
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      _loadAds();
      _numRewardedInterstitialLoadAttempts = 0;

      debugPrint(
          'Reward ads is not loaded yet. Please wait or try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            _isLoading = true;
          });
          _showRewardAd();
        },
        child: Card(
            elevation: widget.titleOnly == false ? 6 : 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
                padding: widget.titleOnly == false
                    ? const EdgeInsets.only(left: 10, right: 10)
                    : null,
                width: widget.width ?? MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        child: _isLoading
                            ? loadingButton(size: 16, color: APP_ACCENT_COLOR)
                            : const Icon(
                                Iconsax.coin,
                                color: APP_ACCENT_COLOR,
                              )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.text,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        if (widget.titleOnly == false)
                          Text(_i18n.translate("watch_ads_earn_2"),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14)),
                      ],
                    ),
                  ],
                ))));
  }
}
