import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAds();
    _showInterstitialAd();
  }

  @override
  void dispose() {
    _ad!.dispose();
    super.dispose();
  }

  void _loadAds() {
    if (!mounted) {
      return;
    }
    RewardedInterstitialAd.load(
        adUnitId: AdManager.interstitialAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            debugPrint('$ad loaded.');
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

  void _showInterstitialAd() {
    if (_isAdLoaded) {
      _isAdLoaded = false;

      // Schedule a timer to load a new ad after a certain time (e.g., 5 seconds)
      Timer(const Duration(seconds: 1), () {
        _loadAds();
      });
    } else {
      _loadAds();
      debugPrint(
          'InterstitialAd is not loaded yet. Please wait or try again later.');
      // Handle the case when the ad is not loaded yet.
      // You might want to show an alternative ad or a placeholder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text("Watch ads and get 1 token."),
      onPressed: () {
        _showInterstitialAd();
      },
    );
  }
}
