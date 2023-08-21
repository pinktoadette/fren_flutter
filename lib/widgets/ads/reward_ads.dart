import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/ad_helper.dart'; // Make sure to import your AdManager with interstitialAdUnitId defined

class RewardAds extends StatefulWidget {
  final String text;
  final Function(dynamic data) onAdStatus;
  const RewardAds({Key? key, required this.text, required this.onAdStatus})
      : super(key: key);

  @override
  State<RewardAds> createState() => _RewardAdsState();
}

class _RewardAdsState extends State<RewardAds> {
  SubscribeController subscribeController = Get.find(tag: 'subscribe');

  RewardedAd? _ad;
  bool _isAdLoaded = false;
  int _numRewardedInterstitialLoadAttempts = 0;
  static int maxFailedLoadAttempts = 3;
  late AppLocalizations _i18n;
  final _purchaseApi = PurchasesApi();
  @override
  void initState() {
    super.initState();
    _loadAds();
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
                onAdImpression: (ad) {},
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

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _ad = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Rewarded Ad failed to load: $error');
            _ad = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _loadAds();
            }
          },
        ));
  }

  void _showRewardAd() {
    if (_isAdLoaded) {
      _isAdLoaded = false;

      _ad!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
        // Reward the user for watching an ad.
        debugPrint(rewardItem.amount.toString());
        widget.onAdStatus(rewardItem.amount);
        await _purchaseApi.getRewards();
        subscribeController.updateCredits(rewardItem.amount.toInt());
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
    return Card(
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: TextButton.icon(
          icon: const Icon(
            Iconsax.coin,
            color: APP_ACCENT_COLOR,
          ),
          label: Container(
            padding: const EdgeInsets.only(left: 15),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                Text(_i18n.translate("watch_ads_earn_10"),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14)),
              ],
            ),
          ),
          onPressed: () {
            _showRewardAd();
          },
        ));
  }
}
