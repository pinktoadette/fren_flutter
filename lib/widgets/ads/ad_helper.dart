// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:machi_app/constants/constants.dart';

class AdManager {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return GOOGLE_BANNER_ADS_ANDROID;
    } else if (Platform.isIOS) {
      /// should be different
      return GOOGLE_BANNER_ADS_IOS;
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    // tester final adUnitId = Platform.isAndroid
    //     ? 'ca-app-pub-3940256099942544/1033173712'
    //     : 'ca-app-pub-3940256099942544/4411468910';

    if (Platform.isAndroid) {
      // 31712 test
      return 'ca-app-pub-3940256099942544/1033173712'; //GOOGLE_INTERSTI_ADS_ANDROID;
    } else if (Platform.isIOS) {
      return IOS_INTERSTITIAL_ID;
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get rewardAds {
    if (Platform.isAndroid) {
      return ANDROID_REWARD_ADS;
    } else if (Platform.isIOS) {
      return IOS_REWARD_ADS;
    }
    throw UnsupportedError("Unsupported platform");
  }
}
