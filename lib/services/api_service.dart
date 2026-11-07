import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/leaderboard_entry.dart';
import '../models/affiliate_post.dart';
import '../models/dashboard_banner.dart';
import '../models/redeem_card.dart';

class ApiRequestException implements Exception {
  final String message;

  const ApiRequestException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // నీ Render బ్యాకెండ్ URL
  static const String baseUrl = 'https://rewardbrick-api.onrender.com/api/v1';
  // AdMantum API (నీ App ID 52007 తో)
  static const String adMantumApi =
      'https://admantum.com/api/v3/offers/?appid=52007&device=android';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    validateStatus: (status) => status! < 500,
  ));
  Map<String, String> _providerLinks = const {};

  String? providerLink(String providerName) =>
      _providerLinks[providerName.toLowerCase()];

  // 1. అకౌంట్ ప్రొఫైల్ & బ్యాలెన్స్ తెచ్చే ఫంక్షన్
  Future<Response?> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/profile/$userId');
      if (response.statusCode != 200) {
        throw ApiRequestException(
          response.data is Map && response.data['message'] is String
              ? response.data['message'] as String
              : 'Could not load your profile. Please try again.',
        );
      }
      final data = response.data;
      if (data is! Map || data['user'] is! Map || data['stats'] is! Map) {
        throw const FormatException('Invalid profile response.');
      }
      return response;
    } on DioException catch (error) {
      throw ApiRequestException(
        error.response?.data is Map && error.response?.data['message'] is String
            ? error.response!.data['message'] as String
            : 'Could not connect to your profile. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await _dio.get('/users/stats/$userId');
      final data = response.data;
      if (data is Map && data['stats'] is Map) {
        return Map<String, dynamic>.from(data['stats'] as Map);
      }
      if (data is Map && data['data'] is Map && data['data']['stats'] is Map) {
        return Map<String, dynamic>.from(data['data']['stats'] as Map);
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<List<DashboardBanner>> getDashboardBanners() async {
    try {
      final response = await _dio.get(
        '/dashboard/banners',
        options: Options(
          connectTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final data = response.data;
      if (response.statusCode != 200 ||
          data is! Map ||
          data['banners'] is! List) {
        throw const FormatException('Invalid dashboard cards response.');
      }
      return (data['banners'] as List).map((banner) {
        if (banner is! Map) {
          throw const FormatException('Invalid dashboard card.');
        }
        return DashboardBanner.fromJson(
          Map<String, dynamic>.from(banner),
        );
      }).toList(growable: false);
    } on DioException catch (error) {
      debugPrint('Dashboard cards could not be loaded: $error');
      rethrow;
    }
  }

  Future<List<AffiliatePost>> getAffiliatePosts() async {
    final response = await _dio.get(
      '/dashboard/affiliate-posts',
      options: Options(
        connectTimeout: const Duration(seconds: 4),
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    final data = response.data;
    if (response.statusCode != 200 || data is! Map || data['posts'] is! List) {
      throw const ApiRequestException('Could not load affiliate posts.');
    }
    return (data['posts'] as List).map((post) {
      if (post is! Map) {
        throw const FormatException('Invalid affiliate post.');
      }
      return AffiliatePost.fromJson(Map<String, dynamic>.from(post));
    }).toList(growable: false);
  }

  Future<List<RedeemCard>> getRedeemCards() async {
    final response = await _dio.get(
      '/dashboard/redeem-cards',
      options: Options(
        connectTimeout: const Duration(seconds: 4),
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    final data = response.data;
    if (response.statusCode != 200 || data is! Map || data['cards'] is! List) {
      throw const ApiRequestException('Could not load redemption cards.');
    }
    return (data['cards'] as List).map((card) {
      if (card is! Map) {
        throw const FormatException('Invalid redemption card.');
      }
      return RedeemCard.fromJson(Map<String, dynamic>.from(card));
    }).toList(growable: false);
  }

  Future<Map<String, String>> getAppContent() async {
    final response = await _dio.get(
      '/dashboard/app-content',
      options: Options(
        connectTimeout: const Duration(seconds: 4),
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    final data = response.data;
    if (response.statusCode != 200 || data is! Map || data['content'] is! Map) {
      throw const ApiRequestException('Could not load app information.');
    }
    final content = Map<String, dynamic>.from(data['content'] as Map);
    return content.map(
      (key, value) => MapEntry(key, value is String ? value : ''),
    );
  }

  Future<LeaderboardPage> getLeaderboard(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    late final Response<dynamic> response;
    try {
      response = await _dio.get(
        '/users/leaderboard',
        queryParameters: {
          'userId': userId,
          'limit': limit,
          'offset': offset,
        },
      );
    } on DioException catch (error) {
      throw ApiRequestException(
        error.response?.data is Map && error.response?.data['message'] is String
            ? error.response!.data['message'] as String
            : 'Could not connect to the leaderboard. Please try again.',
      );
    }

    final data = response.data;
    if (response.statusCode != 200 ||
        data is! Map ||
        data['entries'] is! List) {
      final message = data is Map && data['message'] is String
          ? data['message'] as String
          : null;
      throw ApiRequestException(
        message ?? 'The leaderboard response was invalid. Please try again.',
      );
    }

    final totalUsers = _integerValue(data['total_users']);
    final hasMore = data['has_more'];
    final currentUserRank = data['current_user_rank'] == null
        ? null
        : _integerValue(data['current_user_rank']);
    final currentUserCoins = data['current_user_coins'] == null
        ? null
        : _integerValue(data['current_user_coins']);
    if (totalUsers == null ||
        totalUsers < 0 ||
        hasMore is! bool ||
        (data['current_user_rank'] != null &&
            (currentUserRank == null || currentUserRank < 1)) ||
        (data['current_user_coins'] != null &&
            (currentUserCoins == null || currentUserCoins < 0)) ||
        ((currentUserRank == null) != (currentUserCoins == null))) {
      throw const FormatException('Invalid leaderboard response.');
    }

    final entries = (data['entries'] as List).map((entry) {
      if (entry is! Map) {
        throw const FormatException('Invalid leaderboard entry.');
      }
      final rank = _integerValue(entry['rank']);
      final coinsEarned = _integerValue(entry['coins_earned']);
      final name = entry['name'];
      final isCurrentUser = entry['is_current_user'];
      if (rank == null ||
          rank < 1 ||
          coinsEarned == null ||
          coinsEarned < 0 ||
          name is! String ||
          isCurrentUser is! bool) {
        throw const FormatException('Invalid leaderboard entry.');
      }
      return LeaderboardEntry(
        rank: rank,
        name: name,
        coinsEarned: coinsEarned,
        isCurrentUser: isCurrentUser,
      );
    }).toList(growable: false);

    return LeaderboardPage(
      entries: entries,
      currentUserRank: currentUserRank,
      currentUserCoins: currentUserCoins,
      totalUsers: totalUsers,
      hasMore: hasMore,
    );
  }

  int? _integerValue(dynamic value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Keep provider offers and backend-managed offers visible together.
  Future<List<dynamic>> getLiveOffers(String userId) async {
    List<dynamic> providerOffers = [];
    List<dynamic> backendOffers = [];
    var providerRequestSucceeded = false;
    var backendRequestSucceeded = false;
    await Future.wait([
      () async {
        try {
          final res = await _dio.get(
            '$adMantumApi&uid=$userId',
            options: Options(
              connectTimeout: const Duration(seconds: 7),
              receiveTimeout: const Duration(seconds: 7),
            ),
          );
          final responseData = res.data;
          providerRequestSucceeded = res.statusCode == 200;
          if (responseData is Map && responseData['success'] == true) {
            final offers = responseData['offers'];
            if (offers is List) providerOffers = offers;
          }
        } catch (error) {
          debugPrint('AdMantum offers could not be loaded: $error');
        }
      }(),
      () async {
        try {
          final res = await _dio.get(
            '/tasks/list',
            queryParameters: {'userId': userId},
            options: Options(
              connectTimeout: const Duration(seconds: 7),
              receiveTimeout: const Duration(seconds: 7),
            ),
          );
          backendRequestSucceeded = res.statusCode == 200;
          final responseData = res.data;
          final dataMap = responseData is Map && responseData['data'] is Map
              ? Map<String, dynamic>.from(responseData['data'] as Map)
              : responseData;
          if (dataMap is Map && dataMap['provider_links'] is Map) {
            _providerLinks = Map<String, dynamic>.from(
              dataMap['provider_links'] as Map,
            ).map(
              (name, value) => MapEntry(name.toLowerCase(), value.toString()),
            );
          }
          if (dataMap is Map && dataMap['offers'] is List) {
            backendOffers = (dataMap['offers'] as List).where((offer) {
              if (offer is! Map) return false;
              if (offer['source'] == 'admin_managed') return true;
              final provider =
                  (offer['provider_name'] ?? '').toString().toLowerCase();
              final link = (offer['offer_link'] ??
                      offer['link_url'] ??
                      offer['target_link'] ??
                      '')
                  .toString();
              return (provider == 'admantum' || provider == 'cpx_research') &&
                  link.isNotEmpty;
            }).toList();
          }
        } catch (error) {
          debugPrint('Backend offers could not be loaded: $error');
        }
      }(),
    ]);

    if (!providerRequestSucceeded && !backendRequestSucceeded) {
      throw const ApiRequestException(
        'Offers could not be loaded. Check your connection and try again.',
      );
    }

    final managedOffers = backendOffers
        .where((offer) => offer is Map && offer['source'] == 'admin_managed')
        .toList();
    final providerKeys = providerOffers
        .map(_offerDeduplicationKey)
        .where((key) => key.isNotEmpty)
        .toSet();
    final unrepresentedManagedOffers = managedOffers.where((offer) {
      final key = _offerDeduplicationKey(offer);
      return key.isEmpty || !providerKeys.contains(key);
    });

    return [...providerOffers, ...unrepresentedManagedOffers];
  }

  String _offerDeduplicationKey(dynamic offer) {
    if (offer is! Map) return '';
    final link = (offer['offer_link'] ?? offer['link_url'] ?? '').toString();
    if (link.isNotEmpty) return link.trim().toLowerCase();
    final id = (offer['id'] ?? offer['offer_id'] ?? '').toString();
    if (id.isNotEmpty) return id.trim().toLowerCase();
    return (offer['offer_title'] ?? offer['title'] ?? offer['name'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  Future<List<dynamic>> getHomeContent(String userId) async {
    return getLiveOffers(userId);
  }

  // 3. రిజిస్ట్రేషన్
  Future<Response?> signup(String name, String email, String pass) async {
    try {
      return await _dio.post('/users/register', data: {
        "full_name": name,
        "email": email,
        "password": pass,
      });
    } catch (e) {
      return null;
    }
  }

  // 4. login
  Future<Response?> login(String email, String password) async {
    try {
      return await _dio
          .post('/users/login', data: {"email": email, "password": password});
    } catch (e) {
      return null;
    }
  }

  // 5. విత్ డ్రాయల్ రిక్వెస్ట్
  Future<Response> redeemCard(String userId, int cardId) async {
    try {
      final response = await _dio.post('/users/withdraw', data: {
        'user_id': userId,
        'redeem_card_id': cardId,
      });
      if (response.statusCode != 200) {
        throw ApiRequestException(
          response.data is Map && response.data['message'] is String
              ? response.data['message'] as String
              : 'Redemption request could not be submitted.',
        );
      }
      return response;
    } on DioException catch (error) {
      throw ApiRequestException(
        error.response?.data is Map && error.response?.data['message'] is String
            ? error.response!.data['message'] as String
            : 'Could not submit your redemption request. Please try again.',
      );
    }
  }

  Future<List<dynamic>> getWithdrawalHistory(String userId) async {
    final response = await _dio.get('/withdrawals/history/$userId');
    final data = response.data;
    if (response.statusCode == 200 &&
        data is Map &&
        data['withdrawals'] is List) {
      return List<dynamic>.from(data['withdrawals'] as List);
    }
    throw const ApiRequestException('Could not load redemption history.');
  }

  Future<List<dynamic>> getTransactionHistory(String userId) async {
    final response = await _dio.get('/wallet/transaction-history/$userId');
    final data = response.data;
    if (response.statusCode == 200 &&
        data is Map &&
        data['transactions'] is List) {
      return List<dynamic>.from(data['transactions'] as List);
    }
    throw const ApiRequestException('Could not load transaction history.');
  }

  Future<Map<String, dynamic>> getWalletActivity(
    String userId, {
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/users/activity/$userId',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map &&
          data['activity'] is List &&
          data['has_more'] is bool) {
        return {
          'activity': List<dynamic>.from(data['activity'] as List),
          'has_more': data['has_more'] as bool,
        };
      }
      throw ApiRequestException(
        data is Map && data['message'] is String
            ? data['message'] as String
            : 'Could not load wallet activity.',
      );
    } on DioException catch (error) {
      throw ApiRequestException(
        error.response?.data is Map && error.response?.data['message'] is String
            ? error.response!.data['message'] as String
            : 'Could not load wallet activity. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> startDailyBonusSession(String userId) async {
    try {
      final response = await _dio.post(
        '/users/daily-bonus/session',
        data: {'userId': userId},
      );
      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map &&
          data['session_id'] is String) {
        return Map<String, dynamic>.from(data);
      }
      throw ApiRequestException(
        data is Map && data['message'] is String
            ? data['message'] as String
            : 'Could not start the daily bonus.',
      );
    } on DioException catch (error) {
      throw ApiRequestException(
        error.response?.data is Map && error.response?.data['message'] is String
            ? error.response!.data['message'] as String
            : 'Could not start the daily bonus. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> getDailyBonusSession(
    String userId,
    String sessionId,
  ) async {
    try {
      final response = await _dio.get(
        '/users/daily-bonus/session/$sessionId',
        queryParameters: {'userId': userId},
      );
      final data = response.data;
      if (response.statusCode == 200 &&
          data is Map &&
          data['verified_ads'] is num &&
          data['claimed'] is bool) {
        return Map<String, dynamic>.from(data);
      }
      throw ApiRequestException(
        data is Map && data['message'] is String
            ? data['message'] as String
            : 'Could not check the daily bonus status.',
      );
    } on DioException catch (error) {
      throw ApiRequestException(
        error.response?.data is Map && error.response?.data['message'] is String
            ? error.response!.data['message'] as String
            : 'Could not check the daily bonus status. Please try again.',
      );
    }
  }
}
