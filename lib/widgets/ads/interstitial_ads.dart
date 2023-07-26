import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/widgets/ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// This example demonstrates inline adaptive banner ads.
///
/// Loads and shows an inline adaptive banner ad in a scrolling view,
/// and reloads the ad when the orientation changes.
class InterstitialAds extends StatefulWidget {
  const InterstitialAds({super.key});

  @override
  _InterstitialAdsState createState() => _InterstitialAdsState();
}

class _InterstitialAdsState extends State<InterstitialAds> {
  InterstitialAd? _ad;
  static const _insets = 16.0;
  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAds();
  }

  @override
  void initState() {
    _loadAds();
    super.initState();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  void _loadAds() {
    InterstitialAd.load(
        adUnitId: AdManager.bannerAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _ad = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _adWidth,
      height: AD_HEIGHT,
      alignment: Alignment.center,
      child: Text(" _ad.show()"),
    );
  }
}
