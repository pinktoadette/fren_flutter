import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/ad_helper.dart'; // Make sure to import your AdManager with interstitialAdUnitId defined

class RewardAds extends StatefulWidget {
  final Function(dynamic data) onAdStatus;
  const RewardAds({Key? key, required this.onAdStatus}) : super(key: key);

  @override
  State<RewardAds> createState() => _RewardAdsState();
}

class _RewardAdsState extends State<RewardAds> {
  RewardedInterstitialAd? _ad;
  bool _isAdLoaded = false;
  int _numRewardedInterstitialLoadAttempts = 0;
  static int maxFailedLoadAttempts = 3;
  late AppLocalizations _i18n;
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
    RewardedInterstitialAd.load(
        adUnitId: AdManager.rewardAds,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
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
            debugPrint('RewardedInterstitialAd failed to load: $error');
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

      _ad!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        // Reward the user for watching an ad.
        debugPrint(rewardItem.amount.toString());
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
    double buttonSize = 150;

    return Center(
        child: SizedBox(
            width: buttonSize + 100,
            height: buttonSize,
            child: OutlinedButton.icon(
              icon: const Icon(
                Iconsax.coin,
                color: APP_ACCENT_COLOR,
              ),
              label: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _i18n.translate("watch_ads"),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              onPressed: () {
                _showRewardAd();
              },
            )));
  }
}
