import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/affiliate_post.dart';
import '../models/dashboard_banner.dart';
import '../models/redeem_card.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../theme_design_system.dart';
import 'auth_screen.dart';
import 'content_webview_screen.dart';
import 'leaderboard_screen.dart';
import 'offer_detail_screen.dart';
import 'wallet_activity_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _background = bgLight;
  static const _deepBlue = textDark;
  static const _blue = primaryDarkBlue;
  static const _shadowBlue = Color(0xFFFFE08A);

  final ApiService _api = ApiService();
  final AdService _adService = AdService();
  final TextEditingController _offerSearchController = TextEditingController();
  final ValueNotifier<String> _offerSearch = ValueNotifier('');
  int _currentIndex = 0;
  String _userId = '';
  String _userName = 'there';
  String _userEmail = '';
  String _referralCode = '';
  num _totalEarned = 0;
  num _offersCompleted = 0;
  num _totalRedeemed = 0;
  num _balance = 0;
  bool _loadingProfile = true;
  bool _hasCachedProfile = false;
  bool _dailyLoading = false;
  bool _withdrawalLoading = false;
  bool _loadingWalletHistory = false;
  bool _loadingOffers = true;
  bool _loadingAffiliatePosts = false;
  bool _loadingRedeemCards = false;
  List<dynamic> _offers = [];
  List<dynamic> _withdrawalHistory = [];
  List<dynamic> _transactionHistory = [];
  List<DashboardBanner> _dashboardBanners = const [];
  List<AffiliatePost> _affiliatePosts = const [];
  List<RedeemCard> _redeemCards = const [];
  bool _dashboardBannersLoaded = false;
  String? _profileError;
  String? _offersError;
  String? _dashboardBannersError;
  String? _affiliatePostsError;
  String? _redeemCardsError;
  String? _walletHistoryError;
  Map<String, String> _appContent = const {};
  bool _appContentLoaded = false;
  bool _loadingAppContent = false;
  String? _appContentError;
  bool _walletHistoryRequested = false;
  String _offerCategory = 'All';
  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _initializeDashboard();
    _adService.loadAd();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_bannerController.hasClients) return;
      final bannerCount = _dashboardBanners.length;
      if (bannerCount < 2) return;
      _bannerIndex = (_bannerIndex + 1) % bannerCount;
      _bannerController.animateToPage(_bannerIndex,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _offerSearchController.dispose();
    _offerSearch.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (!mounted) return;
    final cachedName = prefs.getString('profile_name');
    final hasCachedProfile = cachedName != null && cachedName.isNotEmpty;
    setState(() {
      _userId = userId;
      _hasCachedProfile = hasCachedProfile;
      if (hasCachedProfile) {
        _userName = cachedName;
        _balance = num.tryParse(prefs.getString('profile_balance') ?? '') ?? 0;
        _totalEarned =
            num.tryParse(prefs.getString('profile_total_earned') ?? '') ?? 0;
        _offersCompleted =
            num.tryParse(prefs.getString('profile_offers_completed') ?? '') ??
                0;
        _totalRedeemed =
            num.tryParse(prefs.getString('profile_total_redeemed') ?? '') ?? 0;
        _loadingProfile = false;
      }
    });
    if (userId.isEmpty) {
      setState(() {
        _loadingProfile = false;
        _loadingOffers = false;
      });
      return;
    }
    unawaited(NotificationService.registerAndRequestPermission(userId));
    await Future.wait([
      _loadProfile(userId),
      _loadOffers(userId),
      _loadDashboardBanners(),
    ]);
  }

  Future<String> _resolveUserId([String? knownUserId]) async {
    if (knownUserId != null) return knownUserId;
    if (_userId.isNotEmpty) return _userId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  Future<void> _loadProfile([String? knownUserId]) async {
    final userId = await _resolveUserId(knownUserId);
    if (userId.isEmpty) {
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }
    try {
      final response = await _api.getUserProfile(userId);
      if (!mounted) return;
      final data = response?.data;
      final user = data is Map && data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : <String, dynamic>{};
      final stats = data is Map && data['stats'] is Map
          ? Map<String, dynamic>.from(data['stats'] as Map)
          : <String, dynamic>{};
      setState(() {
        _userName = (user['name'] ??
                user['full_name'] ??
                user['display_name'] ??
                'there')
            .toString();
        _userEmail = (user['email'] ?? '').toString();
        _referralCode =
            (user['referral_code'] ?? user['referralCode'] ?? '').toString();
        _balance = user['wallet_balance'] is num
            ? user['wallet_balance'] as num
            : num.tryParse('${user['wallet_balance'] ?? 0}') ?? 0;
        _totalEarned = _numberValue(user['total_earned'] ??
            user['coins_earned'] ??
            user['lifetime_earnings'] ??
            stats['total_earned'] ??
            stats['coins_earned']);
        _offersCompleted = _numberValue(user['offers_completed'] ??
            user['completed_offers'] ??
            user['offers_tried'] ??
            stats['offers_completed']);
        _totalRedeemed =
            _numberValue(user['coins_redeemed'] ?? stats['coins_redeemed']);
        _loadingProfile = false;
        _profileError = null;
        _hasCachedProfile = true;
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setString('profile_name', _userName),
          prefs.setString('profile_balance', '$_balance'),
          prefs.setString('profile_total_earned', '$_totalEarned'),
          prefs.setString('profile_offers_completed', '$_offersCompleted'),
          prefs.setString('profile_total_redeemed', '$_totalRedeemed'),
        ]);
      } catch (error) {
        debugPrint('Profile details could not be cached: $error');
      }
    } on ApiRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _profileError = error.message;
        _loadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Profile load failed: $error');
      setState(() {
        _profileError = 'Could not load your profile. Please try again.';
        _loadingProfile = false;
      });
    }
  }

  num _numberValue(dynamic value) {
    if (value is num) return value;
    return num.tryParse('$value') ?? 0;
  }

  Future<void> _copyReferralCode() async {
    if (_referralCode.isEmpty) {
      _showMessage('Referral code is not available yet.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: _referralCode));
    if (!mounted) return;
    _showMessage('Referral code copied.');
  }

  Future<void> _loadOffers([String? knownUserId]) async {
    if (mounted) {
      setState(() {
        _loadingOffers = true;
        _offersError = null;
      });
    }
    final userId = await _resolveUserId(knownUserId);
    if (userId.isEmpty) {
      if (mounted) setState(() => _loadingOffers = false);
      return;
    }
    try {
      final offers = await _api.getHomeContent(userId);
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _loadingOffers = false;
        _offersError = null;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Affiliate posts could not be loaded: $error');
      setState(() {
        _offers = [];
        _loadingOffers = false;
        _offersError = error is ApiRequestException
            ? error.message
            : 'Could not load offers. Please try again.';
      });
    }
  }

  Future<void> _loadDashboardBanners() async {
    try {
      final banners = await _api.getDashboardBanners();
      if (!mounted) return;
      if (_bannerController.hasClients) _bannerController.jumpToPage(0);
      setState(() {
        _dashboardBanners = banners;
        _dashboardBannersLoaded = true;
        _dashboardBannersError = null;
        _bannerIndex = 0;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Dashboard posters could not be loaded: $error');
      setState(() {
        _dashboardBanners = const [];
        _dashboardBannersLoaded = true;
        _dashboardBannersError = 'Posters could not be loaded.';
      });
    }
  }

  Future<void> _loadAffiliatePosts() async {
    if (_loadingAffiliatePosts) return;
    setState(() {
      _loadingAffiliatePosts = true;
      _affiliatePostsError = null;
    });
    try {
      final posts = await _api.getAffiliatePosts();
      if (!mounted) return;
      setState(() {
        _affiliatePosts = posts;
        _loadingAffiliatePosts = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Redemption cards could not be loaded: $error');
      setState(() {
        _affiliatePosts = const [];
        _affiliatePostsError =
            'Affiliate posts could not be loaded. Try again.';
        _loadingAffiliatePosts = false;
      });
    }
  }

  Future<void> _loadRedeemCards() async {
    if (_loadingRedeemCards) return;
    setState(() {
      _loadingRedeemCards = true;
      _redeemCardsError = null;
    });
    try {
      final cards = await _api.getRedeemCards();
      if (!mounted) return;
      setState(() {
        _redeemCards = cards;
        _loadingRedeemCards = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('App information could not be loaded: $error');
      setState(() {
        _redeemCards = const [];
        _redeemCardsError = 'Redemption cards could not be loaded. Try again.';
        _loadingRedeemCards = false;
      });
    }
  }

  Future<void> _loadAppContent() async {
    if (_loadingAppContent) return;
    setState(() {
      _loadingAppContent = true;
      _appContentError = null;
    });
    try {
      final content = await _api.getAppContent();
      if (!mounted) return;
      setState(() {
        _appContent = content;
        _appContentLoaded = true;
        _loadingAppContent = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _appContentError = 'App information could not be loaded.';
        _loadingAppContent = false;
      });
    }
  }

  Future<void> _openAppPage(String key, String title) async {
    if (!_appContentLoaded) await _loadAppContent();
    if (!mounted) return;
    final pageText = _appContent[key]?.trim() ?? '';
    if (_appContentError != null) {
      _showMessage(_appContentError!);
      return;
    }
    if (pageText.isEmpty) {
      _showMessage('$title has not been published yet.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: SelectableText(pageText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport({
    required String subject,
    required String body,
  }) async {
    if (!_appContentLoaded) await _loadAppContent();
    if (!mounted) return;
    final email = _appContent['support_email']?.trim() ?? '';
    if (_appContentError != null) {
      _showMessage(_appContentError!);
      return;
    }
    if (email.isEmpty) {
      _showMessage('Support contact has not been configured yet.');
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );
    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      _showMessage('Unable to open an email app on this device.');
    }
  }

  Future<void> _rateApp() async {
    if (!_appContentLoaded) await _loadAppContent();
    if (!mounted) return;
    final storeUrl = _appContent['store_url']?.trim() ?? '';
    final uri = Uri.tryParse(storeUrl);
    if (_appContentError != null) {
      _showMessage(_appContentError!);
      return;
    }
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      _showMessage('The app store link has not been configured yet.');
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage('Unable to open the app store link.');
    }
  }

  Future<void> _loadWalletHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) return;
    if (mounted) setState(() => _loadingWalletHistory = true);
    try {
      final results = await Future.wait([
        _api.getWithdrawalHistory(userId),
        _api.getTransactionHistory(userId),
      ]);
      if (!mounted) return;
      setState(() {
        _withdrawalHistory = results[0];
        _transactionHistory = results[1];
        _loadingWalletHistory = false;
        _walletHistoryRequested = true;
        _walletHistoryError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingWalletHistory = false;
        _walletHistoryRequested = false;
        _walletHistoryError = 'Wallet history could not be loaded. Try again.';
      });
    }
  }

  Future<void> _logout() async {
    await NotificationService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  Future<void> _openGatedContent(String title, String url,
      {bool external = false,
      LaunchMode externalLaunchMode = LaunchMode.externalApplication}) async {
    if (_userId.isEmpty) return;
    _adService.showAdGate(context, () {
      if (!mounted) return;
      if (external) {
        unawaited(_launchExternalOffer(url, mode: externalLaunchMode));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContentWebviewScreen(url: url, title: title),
        ),
      ).then((_) => _loadProfile());
    });
  }

  void _openProviderContent(String title, String providerName) {
    final url = _api.providerLink(providerName);
    final uri = url == null ? null : Uri.tryParse(url);
    if (url == null ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty) {
      _showMessage('$title is not configured yet. Please try again later.');
      return;
    }
    _openGatedContent(title, url);
  }

  Future<void> _launchExternalOffer(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final uri = _externalOfferUri(url);
    if (uri == null || !['https', 'market'].contains(uri.scheme)) {
      _showMessage('This offer link is invalid.');
      return;
    }
    final opened = await launchUrl(uri, mode: mode);
    if (!opened && mounted) {
      _showMessage('Unable to open this offer on your device.');
    }
  }

  Uri? _externalOfferUri(String url) {
    if (url.startsWith('intent://')) {
      final intentParts = url.split('#Intent;');
      if (intentParts.length == 2) {
        final schemeMatch = RegExp(r'(?:^|;)scheme=([^;]+)').firstMatch(
          intentParts[1],
        );
        final scheme = schemeMatch?.group(1);
        if (scheme != null && scheme.isNotEmpty) {
          return Uri.tryParse('$scheme://${intentParts[0].substring(9)}');
        }
      }
    }
    return Uri.tryParse(url);
  }

  Future<void> _startOfferTask(Map<dynamic, dynamic> data) async {
    final url =
        (data['offer_link'] ?? data['link_url'] ?? data['target_link'] ?? '')
            .toString()
            .trim();
    if (url.isEmpty) {
      _showMessage('This offer is temporarily unavailable.');
      return;
    }

    final uri = _externalOfferUri(url);
    final openIn = (data['open_in'] ?? 'auto').toString().toLowerCase();
    final isPlayStoreUrl = uri?.host == 'play.google.com' &&
        uri!.path.startsWith('/store/apps/details');
    final packageName =
        isPlayStoreUrl ? uri.queryParameters['id']?.trim() ?? '' : '';
    final shouldOpenPlayStore =
        isPlayStoreUrl && (openIn == 'play_store' || openIn == 'auto');

    if (shouldOpenPlayStore && packageName.isNotEmpty) {
      final marketUri = Uri(
        scheme: 'market',
        host: 'details',
        queryParameters: {'id': packageName},
      );
      final opened = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened || !mounted) return;
      await _launchExternalOffer(
        'https://play.google.com/store/apps/details?id=${Uri.encodeQueryComponent(packageName)}',
      );
      return;
    }

    await _openGatedContent(
      (data['offer_title'] ?? data['title'] ?? 'Offer').toString(),
      url,
      external: true,
      externalLaunchMode: openIn == 'browser'
          ? LaunchMode.inAppBrowserView
          : LaunchMode.externalApplication,
    );
  }

  Future<void> _claimDailyBonus() async {
    if (_userId.isEmpty || _dailyLoading) return;
    setState(() => _dailyLoading = true);
    try {
      final session = await _api.startDailyBonusSession(_userId);
      final sessionId = session['session_id'] as String;
      final verifiedAds = _numberValue(session['verified_ads']).toInt();
      final prefs = await SharedPreferences.getInstance();
      const pendingSessionKey = 'daily_bonus_pending_session';
      const localAdsKey = 'daily_bonus_local_ads';
      final sameSession = prefs.getString(pendingSessionKey) == sessionId;
      var localAds = sameSession ? prefs.getInt(localAdsKey) ?? 0 : 0;
      if (!sameSession) {
        await prefs.setString(pendingSessionKey, sessionId);
        await prefs.setInt(localAdsKey, 0);
      }
      final remainingAds =
          (3 - (verifiedAds > localAds ? verifiedAds : localAds)).clamp(0, 3);

      for (var index = 0; index < remainingAds; index++) {
        final watchedAd = await _adService.showRewardedAd(
          userId: _userId,
          customData: sessionId,
        );
        if (!mounted) return;
        if (!watchedAd) {
          _showMessage(
              'A rewarded ad was not completed. Your verified progress is saved.');
          return;
        }
        localAds++;
        await prefs.setInt(localAdsKey, localAds);
      }

      for (var attempt = 0; attempt < 15; attempt++) {
        final status = await _api.getDailyBonusSession(_userId, sessionId);
        if (!mounted) return;
        if (status['claimed'] == true) {
          await prefs.remove(pendingSessionKey);
          await prefs.remove(localAdsKey);
          _showMessage('Daily bonus claimed: 5 coins (₹0.50).');
          await Future.wait([
            _loadProfile(),
            if (_walletHistoryRequested) _loadWalletHistory(),
          ]);
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      _showMessage(
        'Your ads were watched. The server is verifying them; check your wallet again shortly.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error is ApiRequestException
          ? error.message
          : 'The daily bonus could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _dailyLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildOffersTab(),
          _buildAffiliateTab(),
          _buildWalletTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        color: _blue,
        onRefresh: () async {
          await Future.wait([
            _loadProfile(),
            _loadOffers(),
            _loadDashboardBanners(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: _loadingProfile ? _skeletonText() : _greeting(),
                ),
                _balanceChip(),
              ],
            ),
            const SizedBox(height: 22),
            FadeInDown(child: _bannerCarousel()),
            const AdMobBannerSlot(),
            const SizedBox(height: 16),
            _dailyBonusCard(),
            const SizedBox(height: 20),
            _leaderboardButton(),
            const SizedBox(height: 28),
            _sectionTitle('Choose your earning lane', 'Two ways to earn more'),
            const SizedBox(height: 14),
            FadeInUp(child: _categoryGrid()),
            const SizedBox(height: 30),
            _sectionTitle('AdMantum offers', 'Earn with verified tasks'),
            const SizedBox(height: 14),
            _offerSearchField(),
            const SizedBox(height: 16),
            FadeInUp(child: _offerFeed()),
          ],
        ),
      ),
    );
  }

  Widget _balanceChip() => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 13, 8),
        decoration: _decoration(18),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://i.ibb.co/7dHt2VVr/Chat-GPT-Image-Aug-9-2026-11-24-40-AM.png',
              cacheWidth: 96,
              cacheHeight: 96,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on,
                  color: accentPeach, size: 28),
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Brick Coin',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _deepBlue.withOpacity(.62),
                      fontWeight: FontWeight.w600)),
              _loadingProfile
                  ? _loadingBlock(38, 17)
                  : Text('$_balance',
                      style: GoogleFonts.poppins(
                          height: 1.1,
                          color: _deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
            ],
          ),
        ]),
      );

  Widget _bannerCarousel() {
    if (!_dashboardBannersLoaded) {
      return Container(
        height: 148,
        padding: const EdgeInsets.all(22),
        decoration: _whiteDecoration(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loadingBlock(132, 16),
            const SizedBox(height: 12),
            _loadingBlock(210, 12),
            const SizedBox(height: 16),
            _loadingBlock(72, 10),
          ],
        ),
      );
    }
    if (_dashboardBannersError != null) {
      return SizedBox(
        height: 148,
        child: Center(
          child: TextButton.icon(
            onPressed: _loadDashboardBanners,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(_dashboardBannersError!),
          ),
        ),
      );
    }
    if (_dashboardBanners.isEmpty) return const SizedBox.shrink();
    final cards = _dashboardBanners
        .map((banner) => BannerCard(
              title: banner.title,
              subtitle: banner.subtitle,
              icon: _bannerIcon(banner.iconName),
              accent: Color(
                int.parse(banner.accentColor.substring(1), radix: 16) |
                    0xFF000000,
              ),
              imageUrl: banner.imageUrl,
              onTap: banner.targetUrl.isEmpty
                  ? null
                  : () => _launchExternalOffer(banner.targetUrl),
            ))
        .toList(growable: false);
    return SizedBox(
      height: 148,
      child: PageView(
        controller: _bannerController,
        onPageChanged: (index) => _bannerIndex = index,
        children: cards,
      ),
    );
  }

  IconData _bannerIcon(String iconName) => switch (iconName) {
        'people' => Icons.people_alt_rounded,
        'trophy' => Icons.emoji_events_rounded,
        'share' => Icons.share_rounded,
        'wallet' => Icons.account_balance_wallet_rounded,
        'gift' => Icons.card_giftcard_rounded,
        'star' => Icons.star_rounded,
        _ => Icons.celebration_rounded,
      };

  Widget _dailyBonusCard() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentCreamy, const Color(0xFFFFEBDD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
            BoxShadow(
                color: Color(0xFFE8CFC0), offset: Offset(5, 5), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            _neoIcon(Icons.card_giftcard_rounded, accentCoral, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily bonus',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, color: _deepBlue)),
                  Text('Watch 3 ads for 5 coins (₹0.50).',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: _deepBlue.withOpacity(.65))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _dailyLoading ? null : _claimDailyBonus,
              child: _dailyLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Claim',
                      style: GoogleFonts.poppins(
                          color: accentCoral, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _leaderboardButton() => InkWell(
        onTap: _userId.isEmpty ? null : _openLeaderboard,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _decoration(22),
          child: Row(
            children: [
              _neoIcon(Icons.emoji_events_rounded, _blue, size: 48),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leaderboard',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _deepBlue)),
                    Text('Tap View to see the current rankings.',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: _deepBlue.withOpacity(.62))),
                  ],
                ),
              ),
              Text('View',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, color: _blue)),
            ],
          ),
        ),
      );

  Future<void> _openLeaderboard() async {
    if (_userId.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaderboardScreen(userId: _userId),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: _headingStyle())),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: _deepBlue.withOpacity(.58))),
        ],
      );

  Widget _categoryGrid() => Row(children: [
        Expanded(
            child: _categoryCard(
                'PREMIUM SURVEYS',
                'Surveys',
                'Tell brands what you think.',
                Icons.poll_rounded,
                _blue,
                () => _openProviderContent('Surveys', 'cpx_research'))),
        const SizedBox(width: 16),
        Expanded(
            child: _categoryCard(
                'FUN GAMES',
                'Games',
                'Play quick games for coins.',
                Icons.sports_esports_rounded,
                _blue,
                () => _openProviderContent('Games', 'gamezop'))),
      ]);

  Widget _categoryCard(String eyebrow, String title, String description,
          IconData icon, Color accent, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: _decoration(22),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(eyebrow,
                    style: GoogleFonts.poppins(
                        fontSize: 7,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w700,
                        color: accent)),
                Row(
                  children: [
                    _neoIcon(icon, accent, size: 36),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _deepBlue)),
                          Text(description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: _deepBlue.withOpacity(.62))),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: accent, size: 19),
                  ],
                ),
              ]),
        ),
      );

  Widget _offerSearchField() => TextField(
        controller: _offerSearchController,
        onChanged: (value) => _offerSearch.value = value.trim(),
        style: GoogleFonts.poppins(fontSize: 13, color: _deepBlue),
        decoration: InputDecoration(
          hintText: 'Search for an offer',
          hintStyle: GoogleFonts.poppins(
              fontSize: 12, color: _deepBlue.withOpacity(.48)),
          prefixIcon: const Icon(Icons.search_rounded, color: _blue),
          suffixIcon: ValueListenableBuilder<String>(
            valueListenable: _offerSearch,
            builder: (context, search, _) => search.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _offerSearchController.clear,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide.none),
        ),
      );

  Widget _offerFeed() => ValueListenableBuilder<String>(
        valueListenable: _offerSearch,
        builder: (context, search, _) {
          if (_loadingOffers) {
            return Column(
              children: List.generate(2, (_) => _offerLoadingCard()),
            );
          }
          if (_offersError != null) {
            return Center(
              child: Column(
                children: [
                  Text(_offersError!, textAlign: TextAlign.center),
                  TextButton.icon(
                    onPressed: _loadOffers,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          final filteredOffers = _filteredOffers(search);
          if (filteredOffers.isEmpty) {
            return search.isEmpty ? _emptyOfferCard() : _emptySearchCard();
          }
          return Column(
              children: filteredOffers
                  .take(8)
                  .map((offer) => _offerCard(offer))
                  .toList());
        },
      );

  List<dynamic> _filteredOffers(String search) {
    return _offers.where((offer) {
      final data = offer is Map ? offer : <dynamic, dynamic>{};
      final title = (data['offer_title'] ?? data['title'] ?? data['name'] ?? '')
          .toString();
      final link =
          (data['offer_link'] ?? data['link_url'] ?? data['target_link'] ?? '')
              .toString();
      if (title.trim().isEmpty || link.trim().isEmpty) return false;
      final searchable = [
        title,
        data['offer_description'],
        data['offer_type'],
      ].join(' ').toLowerCase();
      final type = (data['offer_type'] ?? '').toString().toLowerCase();
      final matchesSearch = searchable.contains(search.toLowerCase());
      final matchesCategory = _offerCategory == 'All' ||
          (_offerCategory == 'Surveys' && type.contains('survey')) ||
          (_offerCategory == 'Games' && type.contains('game')) ||
          (_offerCategory == 'Tasks' &&
              !type.contains('survey') &&
              !type.contains('game'));
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _offerCard(dynamic offer) {
    final data = offer is Map ? offer : <dynamic, dynamic>{};
    final title =
        (data['offer_title'] ?? data['title'] ?? data['name'] ?? '').toString();
    final description =
        (data['offer_description'] ?? data['description'] ?? '').toString();
    final coins = data['offer_virtual_currency'] ??
        data['coins'] ??
        data['reward'] ??
        data['payout'] ??
        '';
    final iconUrl = (data['offer_image'] ??
            data['icon'] ??
            data['icon_url'] ??
            data['image'] ??
            '')
        .toString();
    return InkWell(
      onTap: () => _openOfferDetails(data),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: _whiteDecoration(18),
        child: Row(children: [
          _offerIcon(iconUrl),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, color: _deepBlue)),
                Text(_offerType(data),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF174A73),
                        fontWeight: FontWeight.w600)),
                Text(description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: _deepBlue.withOpacity(.62))),
              ])),
          const SizedBox(width: 8),
          if (coins.toString().isNotEmpty)
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    color: _blue, borderRadius: BorderRadius.circular(13)),
                child: Text('+$coins',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }

  String _offerType(Map<dynamic, dynamic> data) {
    final type = (data['offer_type'] ?? 'Task').toString().toUpperCase();
    return '$type  •  Tap for details';
  }

  void _openOfferDetails(Map<dynamic, dynamic> data) {
    final url =
        (data['offer_link'] ?? data['link_url'] ?? data['target_link'] ?? '')
            .toString();
    if (url.isEmpty) {
      _showMessage('This offer is temporarily unavailable.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfferDetailScreen(
          offer: data,
          onStartTask: () => _startOfferTask(data),
        ),
      ),
    );
  }

  Widget _offerIcon(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: url.isEmpty
            ? Container(
                width: 56,
                height: 56,
                color: _shadowBlue,
                child: const Icon(Icons.download_rounded, color: _blue))
            : Image.network(url,
                width: 56,
                height: 56,
                cacheWidth: 168,
                cacheHeight: 168,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: _shadowBlue,
                    child: const Icon(Icons.apps_rounded, color: _blue))),
      );

  Widget _emptyOfferCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: _decoration(18),
        child: Row(children: [
          _neoIcon(Icons.refresh_rounded, _blue, size: 48),
          const SizedBox(width: 14),
          Expanded(
              child: Text('No offers are available right now.',
                  style:
                      GoogleFonts.poppins(color: _deepBlue.withOpacity(.7)))),
        ]),
      );

  Widget _emptySearchCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: _whiteDecoration(18),
        child: Text('No offers match your search.',
            style: GoogleFonts.poppins(color: _deepBlue.withOpacity(.7))),
      );

  Widget _greeting() => _profileError == null || _hasCachedProfile
      ? Row(
          children: [
            Image.asset(
              'assets/illustrations/rewardbrick_logo.png',
              width: 52,
              height: 46,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello,',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: _deepBlue.withOpacity(.65))),
                  Text(_userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: _deepBlue)),
                ],
              ),
            ),
          ],
        )
      : InkWell(
          onTap: _loadProfile,
          child: Text(
            'Profile unavailable · tap to retry',
            style: GoogleFonts.poppins(fontSize: 12, color: accentCoral),
          ),
        );

  Widget _skeletonText() => Container(
        width: 170,
        height: 48,
        decoration: _decoration(14),
      );

  Widget _loadingBlock(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: primaryLightBlue.withOpacity(.48),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );

  Widget _offerLoadingCard() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: _whiteDecoration(18),
        child: Row(
          children: [
            _loadingBlock(64, 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _loadingBlock(150, 14),
                  const SizedBox(height: 10),
                  _loadingBlock(170, 10),
                  const SizedBox(height: 12),
                  _loadingBlock(82, 11),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _balancePanel() => Container(
        padding: const EdgeInsets.all(22),
        decoration: _decoration(24),
        child: Row(
          children: [
            _neoIcon(Icons.savings_rounded, _blue, size: 52),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet balance',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: _deepBlue.withOpacity(.65))),
                _loadingProfile
                    ? _loadingBlock(112, 28)
                    : Text('$_balance coins',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: _deepBlue)),
              ],
            ),
          ],
        ),
      );

  Widget _actionCard(
          String title, String subtitle, IconData icon, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _decoration(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _neoIcon(icon, _blue, size: 44),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, color: _deepBlue)),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: _deepBlue.withOpacity(.62))),
            ],
          ),
        ),
      );

  Widget _buildOffersTab() => SafeArea(
        child: RefreshIndicator(
          color: _blue,
          onRefresh: _loadOffers,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore offers', style: _headingStyle()),
                        const SizedBox(height: 4),
                        Text('Choose a task that fits your time.',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _deepBlue.withOpacity(.62))),
                      ],
                    ),
                  ),
                  _neoIcon(Icons.bolt_rounded, _blue, size: 48),
                ],
              ),
              const SizedBox(height: 20),
              if (_dashboardBanners.isNotEmpty) ...[
                _bannerCarousel(),
                const SizedBox(height: 16),
              ],
              const AdMobBannerSlot(),
              _offerSearchField(),
              const SizedBox(height: 14),
              _offerCategoryFilters(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${_filteredOffers(_offerSearch.value).length} available',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _deepBlue)),
                  Text('Live partner feed',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: _deepBlue.withOpacity(.55))),
                ],
              ),
              const SizedBox(height: 12),
              _offerFeed(),
            ],
          ),
        ),
      );

  Widget _offerCategoryFilters() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Surveys', 'Games', 'Tasks'].map((category) {
            final selected = _offerCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 9),
              child: ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) => setState(() => _offerCategory = category),
                selectedColor: _blue,
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: selected ? Colors.white : _deepBlue,
                    fontWeight: FontWeight.w600),
                side: BorderSide(color: selected ? _blue : _shadowBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildAffiliateTab() => SafeArea(
        child: RefreshIndicator(
          color: _blue,
          onRefresh: _loadAffiliatePosts,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
            children: [
              Text('Affiliate offers', style: _headingStyle()),
              const SizedBox(height: 5),
              Text(
                'Products and links published by RewardBrick.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: _deepBlue.withOpacity(.62)),
              ),
              const SizedBox(height: 18),
              if (_loadingAffiliatePosts)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_affiliatePostsError != null)
                Center(
                  child: Column(
                    children: [
                      Text(_affiliatePostsError!, textAlign: TextAlign.center),
                      TextButton.icon(
                        onPressed: _loadAffiliatePosts,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else if (_affiliatePosts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _whiteDecoration(18),
                  child: Text(
                    'No affiliate posts are available right now.',
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.poppins(color: _deepBlue.withOpacity(.65)),
                  ),
                )
              else
                ..._affiliatePosts.map(_affiliatePostCard),
            ],
          ),
        ),
      );

  Widget _affiliatePostCard(AffiliatePost post) => InkWell(
        onTap: () => _launchExternalOffer(post.destinationUrl),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: _whiteDecoration(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.imageUrl.isNotEmpty)
                Image.network(
                  post.imageUrl,
                  width: double.infinity,
                  height: 190,
                  cacheWidth: 960,
                  cacheHeight: 570,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 96,
                    child:
                        Center(child: Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, color: _deepBlue)),
                    if (post.message.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(post.message,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: _deepBlue.withOpacity(.7))),
                    ],
                    const SizedBox(height: 10),
                    Text('View offer',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _blue,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildWalletTab() => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text('Your wallet', style: _headingStyle()),
            const SizedBox(height: 16),
            _balancePanel(),
            const SizedBox(height: 22),
            _coinConversionTable(),
            const SizedBox(height: 24),
            Text('Redeem gift cards', style: _headingStyle()),
            const SizedBox(height: 10),
            _redeemCardSection(),
            if (_withdrawalLoading) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 28),
            _walletHistorySection(),
          ],
        ),
      );

  Future<void> _ensureWalletHistoryLoaded() async {
    if (_walletHistoryRequested) return;
    await _loadWalletHistory();
  }

  Future<void> _openAllWalletActivity() async {
    if (_userId.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletActivityScreen(api: _api, userId: _userId),
      ),
    );
    if (mounted && _walletHistoryRequested) {
      await _loadWalletHistory();
    }
  }

  Widget _walletHistorySection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent activity', style: _headingStyle()),
              Row(
                children: [
                  TextButton(
                    onPressed: _openAllWalletActivity,
                    child: const Text('View all'),
                  ),
                  IconButton(
                    onPressed:
                        _loadingWalletHistory ? null : _loadWalletHistory,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ],
          ),
          if (_loadingWalletHistory)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator()))
          else if (_walletHistoryError != null)
            Column(
              children: [
                Text(_walletHistoryError!, textAlign: TextAlign.center),
                TextButton.icon(
                  onPressed: _loadWalletHistory,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            )
          else if (_withdrawalHistory.isEmpty && _transactionHistory.isEmpty)
            _walletEmptyState()
          else ...[
            ..._withdrawalHistory.take(5).map(_withdrawalHistoryTile),
            ..._transactionHistory.take(5).map(_transactionHistoryTile),
          ],
        ],
      );

  Widget _coinConversionTable() => Container(
        padding: const EdgeInsets.all(16),
        decoration: _whiteDecoration(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coin conversion',
                style: _headingStyle().copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text('10 coins = ₹1',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, color: _blue)),
            const SizedBox(height: 10),
            ...const [
              (1000, 100),
              (5000, 500),
              (10000, 1000),
              (15000, 1500),
              (25000, 2500),
              (50000, 5000),
              (100000, 10000),
            ].map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${row.$1} coins',
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text('₹${row.$2}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _redeemCardSection() {
    if (_loadingRedeemCards) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_redeemCardsError != null) {
      return Column(
        children: [
          Text(_redeemCardsError!, textAlign: TextAlign.center),
          TextButton.icon(
            onPressed: _loadRedeemCards,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      );
    }
    if (_redeemCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _whiteDecoration(18),
        child: Text(
          'No gift cards are available right now.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: _deepBlue.withOpacity(.65)),
        ),
      );
    }
    return Column(
      children: _redeemCards.map(_redeemCardTile).toList(growable: false),
    );
  }

  Widget _redeemCardTile(RedeemCard card) {
    final canRedeem =
        _balance >= card.minimumCoins && _balance >= card.coinsRequired;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _whiteDecoration(16),
      child: Row(
        children: [
          _neoIcon(Icons.card_giftcard_rounded, _blue, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, color: _deepBlue)),
                Text('₹${card.denominationInr} · ${card.coinsRequired} coins',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: _deepBlue.withOpacity(.65))),
                Text('Minimum balance: ${card.minimumCoins} coins',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: _deepBlue.withOpacity(.55))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: !canRedeem || _withdrawalLoading
                ? null
                : () => _requestRedemption(card),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestRedemption(RedeemCard card) async {
    if (_userId.isEmpty || _withdrawalLoading) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm gift-card request'),
        content: Text(
          'Request a ₹${card.denominationInr} ${card.title} card for ${card.coinsRequired} coins? The amount will be reserved from your balance while the admin processes it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _withdrawalLoading = true);
    try {
      final response = await _api.redeemCard(_userId, card.id);
      if (!mounted) return;
      setState(() => _withdrawalLoading = false);
      final message = response.data is Map && response.data['message'] is String
          ? response.data['message'] as String
          : 'Redemption request submitted.';
      _showMessage(message);
      await Future.wait([_loadProfile(), _loadWalletHistory()]);
    } catch (error) {
      if (!mounted) return;
      setState(() => _withdrawalLoading = false);
      _showMessage(error is ApiRequestException
          ? error.message
          : 'Redemption request could not be submitted.');
    }
  }

  Widget _walletEmptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _whiteDecoration(18),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 38, color: _deepBlue.withOpacity(.42)),
            const SizedBox(height: 8),
            Text('No wallet activity yet',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, color: _deepBlue)),
            const SizedBox(height: 3),
            Text('Your transactions and withdrawals will appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: _deepBlue.withOpacity(.62))),
          ],
        ),
      );

  Widget _withdrawalHistoryTile(dynamic item) {
    final data = item is Map ? item : <dynamic, dynamic>{};
    final amount = data['amount_coins'] ?? data['amount'] ?? 0;
    final cardTitle =
        (data['card_title'] ?? data['method'] ?? 'Gift card').toString();
    final status = (data['status'] ?? 'pending').toString();
    final voucherReference = data['voucher_reference'];
    final activityStatus =
        voucherReference is String && voucherReference.isNotEmpty
            ? '$status · Voucher: $voucherReference'
            : status;
    return _historyTile(
      Icons.card_giftcard_rounded,
      '$cardTitle redemption',
      '$amount coins',
      activityStatus,
      false,
    );
  }

  Widget _transactionHistoryTile(dynamic item) {
    final data = item is Map ? item : <dynamic, dynamic>{};
    final amount = data['amount'] ?? data['coins'] ?? 0;
    final reason =
        (data['reason'] ?? data['type'] ?? 'Wallet transaction').toString();
    final type = (data['type'] ?? 'credit').toString().toLowerCase();
    return _historyTile(Icons.swap_vert_rounded, reason, '$amount coins', type,
        type == 'credit');
  }

  Widget _historyTile(IconData icon, String title, String amount, String status,
          bool positive) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _whiteDecoration(16),
        child: Row(
          children: [
            Icon(icon, color: positive ? successGreen : accentCoral),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: _deepBlue)),
                  Text(status,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: _deepBlue.withOpacity(.58))),
                ],
              ),
            ),
            Text('${positive ? '+' : '-'}$amount',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: positive ? successGreen : accentCoral)),
          ],
        ),
      );

  Widget _buildProfileTab() => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          children: [
            Text('Your profile', style: _headingStyle()),
            const SizedBox(height: 6),
            Text('Keep track of your RewardBrick journey.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: _deepBlue.withOpacity(.62))),
            const SizedBox(height: 20),
            _profileIdentityCard(),
            const SizedBox(height: 22),
            Text('Your progress', style: _headingStyle()),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _profileStat('Balance', '$_balance',
                        Icons.account_balance_wallet_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _profileStat(
                        'Earned', '$_totalEarned', Icons.trending_up_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _profileStat(
                        'Offers', '$_offersCompleted', Icons.task_alt_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _profileStat('Redeemed', '$_totalRedeemed',
                        Icons.card_giftcard_rounded)),
              ],
            ),
            const SizedBox(height: 22),
            _profileAction(
                Icons.bug_report_outlined,
                'Bug report',
                'Send a problem report to support.',
                () => _contactSupport(
                      subject: 'RewardBrick bug report',
                      body:
                          'Describe what happened, the screen you were using, and steps to reproduce it.',
                    )),
            const SizedBox(height: 12),
            _profileAction(Icons.history_rounded, 'Reward history',
                'View redemptions and wallet transactions.', () {
              setState(() => _currentIndex = 3);
              unawaited(_ensureWalletHistoryLoaded());
              unawaited(_loadRedeemCards());
            }),
            const SizedBox(height: 12),
            _profileAction(
                Icons.policy_outlined,
                'Terms & conditions',
                'Read the currently published terms.',
                () => _openAppPage('terms', 'Terms & conditions')),
            const SizedBox(height: 12),
            _profileAction(
                Icons.info_outline_rounded,
                'About us',
                'Learn about RewardBrick.',
                () => _openAppPage('about', 'About us')),
            const SizedBox(height: 12),
            _profileAction(Icons.star_outline_rounded, 'Rate us',
                'Open RewardBrick in your app store.', _rateApp),
            const SizedBox(height: 12),
            _profileAction(
                Icons.notifications_active_outlined,
                'Enable notifications',
                'Choose whether RewardBrick can send you updates.', () async {
              final enabled = await NotificationService.requestPermission();
              if (mounted) {
                _showMessage(enabled
                    ? 'Notifications enabled.'
                    : 'Notifications are unavailable or permission was not granted.');
              }
            }),
            const SizedBox(height: 12),
            _profileAction(
                Icons.delete_outline_rounded,
                'Delete account',
                'Email support to request account deletion.',
                () => _contactSupport(
                      subject: 'RewardBrick account deletion request',
                      body:
                          'I request deletion of my RewardBrick account.\n\nAccount email: $_userEmail\nUser ID: $_userId\n\nPlease confirm the required identity verification and next steps.',
                    )),
            const SizedBox(height: 24),
            _primaryButton('Log out', Icons.logout_rounded, _logout),
          ],
        ),
      );

  Widget _profileIdentityCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: _whiteDecoration(22),
        child: Row(
          children: [
            _neoIcon(Icons.person_rounded, _blue, size: 62),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _deepBlue)),
                  const SizedBox(height: 3),
                  Text(_userEmail.isEmpty ? 'Email unavailable' : _userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: _deepBlue.withOpacity(.62))),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            _referralCode.isEmpty
                                ? 'Referral code unavailable'
                                : 'Referral code: $_referralCode',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: accentCoral,
                                fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        tooltip: 'Copy referral code',
                        onPressed:
                            _referralCode.isEmpty ? null : _copyReferralCode,
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        color: accentCoral,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _profileStat(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _decoration(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _blue, size: 21),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _deepBlue)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: _deepBlue.withOpacity(.62))),
          ],
        ),
      );

  Widget _profileAction(
          IconData icon, String title, String subtitle, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: _whiteDecoration(18),
          child: Row(
            children: [
              Icon(icon, color: _blue, size: 25),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, color: _deepBlue)),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: _deepBlue.withOpacity(.62))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: _deepBlue.withOpacity(.55)),
            ],
          ),
        ),
      );

  Widget _tabScaffold(String title, String subtitle, IconData icon,
          void Function(String) action) =>
      SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _neoIcon(icon, _blue, size: 80),
                const SizedBox(height: 20),
                Text(title, style: _headingStyle()),
                const SizedBox(height: 8),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.poppins(color: _deepBlue.withOpacity(.65))),
                const SizedBox(height: 24),
                _primaryButton('Browse offers', Icons.open_in_new_rounded,
                    () => action('Offers are loading soon.')),
              ],
            ),
          ),
        ),
      );

  BoxDecoration _decoration(double radius) => BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFFFE7A8)),
        boxShadow: [
          BoxShadow(
              color: textDark.withOpacity(.06),
              offset: const Offset(0, 4),
              blurRadius: 12),
        ],
      );

  BoxDecoration _whiteDecoration(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFF0E8D3)),
        boxShadow: [
          BoxShadow(
              color: textDark.withOpacity(.055),
              offset: const Offset(0, 3),
              blurRadius: 10),
        ],
      );

  Widget _neoIcon(IconData icon, Color color, {double size = 48}) => Container(
        width: size,
        height: size,
        decoration: _decoration(size / 3),
        child: Icon(icon, color: color, size: size * .48),
      );

  TextStyle _headingStyle() => GoogleFonts.poppins(
      fontSize: 22, fontWeight: FontWeight.w700, color: _deepBlue);

  Widget _primaryButton(String label, IconData icon, VoidCallback onTap) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );

  Widget _buildBottomNavigationBar() => NavigationBar(
        backgroundColor: _background,
        indicatorColor: _shadowBlue,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) async {
          setState(() => _currentIndex = index);
          if (index == 2) {
            await _loadAffiliatePosts();
          } else if (index == 3) {
            await _loadRedeemCards();
            await _ensureWalletHistoryLoaded();
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.bolt_rounded), label: 'Offers'),
          NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Affiliate'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Wallet'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      );

  void _showMessage(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

class BannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String imageUrl;
  final VoidCallback? onTap;

  const BannerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.imageUrl = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: textDark.withOpacity(.12),
                offset: const Offset(0, 4),
                blurRadius: 12),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                cacheWidth: 960,
                cacheHeight: 444,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            if (imageUrl.isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(.5),
                      Colors.black.withOpacity(.12),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(.92),
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(icon, color: Colors.white.withOpacity(.9), size: 58),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
