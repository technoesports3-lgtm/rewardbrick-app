import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static Future<void>? _adsInitialization;

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isShowingRewardedAd = false;
  bool _rewardGranted = false;

  // Use the Google test ID until a production ID is supplied at build time.
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _adUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID',
    defaultValue: _testAdUnitId,
  );

  void loadAd() {
    if (_isAdLoaded || _isAdLoading) return;
    _isAdLoading = true;
    (_adsInitialization ??= MobileAds.instance.initialize().then((_) {}))
        .then((_) {
      RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _isAdLoading = false;
            _rewardedAd?.dispose();
            _rewardedAd = ad;
            _isAdLoaded = true;
            debugPrint('Rewarded ad loaded.');
          },
          onAdFailedToLoad: (err) {
            _isAdLoading = false;
            _rewardedAd = null;
            _isAdLoaded = false;
            debugPrint('Rewarded ad failed to load: ${err.message}');
          },
        ),
      );
    }).catchError((Object error) {
      _isAdLoading = false;
      _adsInitialization = null;
      debugPrint('Google Mobile Ads could not initialize: $error');
    });
  }

  Future<bool> showRewardedAd() async {
    if (_isShowingRewardedAd) return false;

    final ad = _rewardedAd;
    if (!_isAdLoaded || ad == null) {
      debugPrint('Rewarded ad is not ready.');
      loadAd();
      return false;
    }

    _rewardedAd = null;
    _isAdLoaded = false;
    _isShowingRewardedAd = true;
    var rewardGranted = false;
    final result = Completer<bool>();

    void finish(bool watched) {
      if (result.isCompleted) return;
      _isShowingRewardedAd = false;
      result.complete(watched);
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAd();
        finish(rewardGranted);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('Rewarded ad failed to show: ${err.message}');
        ad.dispose();
        loadAd();
        finish(false);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          rewardGranted = true;
        },
      );
    } catch (error) {
      debugPrint('Rewarded ad show error: $error');
      if (!result.isCompleted) {
        ad.dispose();
        loadAd();
        finish(false);
      }
    }

    return result.future;
  }

  void showAdGate(BuildContext context, VoidCallback onRewardEarned) {
    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('Rewarded ad not ready; continuing without an ad.');
      onRewardEarned();
      loadAd();
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    _isAdLoaded = false;
    _rewardGranted = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('Rewarded ad shown.'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadAd();
        onRewardEarned();
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      if (_rewardGranted) return;
      _rewardGranted = true;
      debugPrint('User earned the rewarded ad reward.');
      onRewardEarned();
    });
  }
}
