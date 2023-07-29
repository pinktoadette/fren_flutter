import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:machi_app/widgets/ads/ad_helper.dart'; // Make sure to import your AdManager with interstitialAdUnitId defined

class InterstitialAds extends StatefulWidget {
  final Function(dynamic data) onAdStatus;
  const InterstitialAds({Key? key, required this.onAdStatus}) : super(key: key);

  @override
  _InterstitialAdsState createState() => _InterstitialAdsState();
}

class _InterstitialAdsState extends State<InterstitialAds> {
  late InterstitialAd _ad;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
    _showInterstitialAd();
  }

  @override
  void dispose() {
    _ad.dispose();
    super.dispose();
  }

  void _loadAds() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                widget.onAdStatus({'status': 'error'});
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                widget.onAdStatus({'status': 'closed'});
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});

          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded) {
      _ad.show();
      _isAdLoaded = false;

      // Schedule a timer to load a new ad after a certain time (e.g., 5 seconds)
      Timer(const Duration(seconds: 5), () {
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
      child: const Text("Ads"),
      onPressed: () {
        _showInterstitialAd();
      },
    );
  }
}
