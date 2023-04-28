import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/widgets/ads/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// This example demonstrates inline adaptive banner ads.
///
/// Loads and shows an inline adaptive banner ad in a scrolling view,
/// and reloads the ad when the orientation changes.
class InlineAdaptiveAds extends StatefulWidget {
  const InlineAdaptiveAds({super.key});

  @override
  _InlineAdaptiveAdsState createState() => _InlineAdaptiveAdsState();
}

class _InlineAdaptiveAdsState extends State<InlineAdaptiveAds> {
  BannerAd? _ad;
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
    BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          debugPrint(
              'Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _adWidth,
      height: AD_HEIGHT,
      alignment: Alignment.center,
      child: _ad != null ? AdWidget(ad: _ad!) : const Text("Your ad here"),
    );
  }
}
