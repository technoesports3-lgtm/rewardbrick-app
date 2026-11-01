import 'package:flutter_test/flutter_test.dart';
import 'package:rewardbrick_app/models/affiliate_post.dart';
import 'package:rewardbrick_app/models/dashboard_banner.dart';
import 'package:rewardbrick_app/models/redeem_card.dart';

void main() {
  group('DashboardBanner', () {
    test('supports previously stored cards without poster URLs', () {
      final banner = DashboardBanner.fromJson({
        'id': 1,
        'title': 'Announcement',
        'subtitle': 'Published by admin',
        'icon_name': 'gift',
        'accent_color': '#00796B',
      });

      expect(banner.imageUrl, isEmpty);
      expect(banner.targetUrl, isEmpty);
    });

    test('keeps the admin-managed poster image URL', () {
      final banner = DashboardBanner.fromJson({
        'id': 2,
        'title': 'Rewards',
        'subtitle': 'Find your next reward',
        'icon_name': 'gift',
        'accent_color': '#1769D2',
        'image_url': 'https://cdn.example.com/reward-poster.jpg',
        'target_url': 'https://example.com/rewards',
      });

      expect(banner.imageUrl, 'https://cdn.example.com/reward-poster.jpg');
      expect(banner.targetUrl, 'https://example.com/rewards');
    });
  });

  group('AffiliatePost', () {
    test('parses admin-managed affiliate content', () {
      final post = AffiliatePost.fromJson({
        'id': 2,
        'title': 'Product',
        'message': 'Published caption',
        'image_url': '',
        'destination_url': 'https://shop.example/product',
      });

      expect(post.title, 'Product');
      expect(post.destinationUrl, 'https://shop.example/product');
    });

    test('rejects non-HTTPS destinations', () {
      expect(
        () => AffiliatePost.fromJson({
          'id': 2,
          'title': 'Product',
          'message': '',
          'image_url': '',
          'destination_url': 'http://shop.example/product',
        }),
        throwsFormatException,
      );
    });
  });

  group('RedeemCard', () {
    test('enforces the 10-coins-per-rupee conversion', () {
      final card = RedeemCard.fromJson({
        'id': 3,
        'title': 'Google Play',
        'denomination_inr': 100,
        'coins_required': 1000,
        'minimum_coins': 1000,
      });

      expect(card.coinsRequired, 1000);
    });

    test('rejects an inconsistent redemption price', () {
      expect(
        () => RedeemCard.fromJson({
          'id': 3,
          'title': 'Google Play',
          'denomination_inr': 100,
          'coins_required': 10000,
          'minimum_coins': 10000,
        }),
        throwsFormatException,
      );
    });
  });
}
