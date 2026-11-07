import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rewardbrick_app/screens/wallet_activity_screen.dart';
import 'package:rewardbrick_app/services/api_service.dart';

class _ActivityApi extends ApiService {
  final List<int> requestedOffsets = [];

  @override
  Future<Map<String, dynamic>> getWalletActivity(
    String userId, {
    int limit = 30,
    int offset = 0,
  }) async {
    requestedOffsets.add(offset);
    final title = offset == 0 ? 'Offer payout' : 'Daily bonus';
    return {
      'activity': [
        {
          'activity_type': 'transaction',
          'activity_id': '$offset',
          'created_at': DateTime(2026, 11, 7).toIso8601String(),
          'amount_coins': offset == 0 ? '25' : '5',
          'title': title,
          'status': 'daily_bonus',
        },
      ],
      'has_more': offset == 0,
    };
  }
}

void main() {
  testWidgets('wallet activity paginates through the backend ledger',
      (tester) async {
    final api = _ActivityApi();
    await tester.pumpWidget(
      MaterialApp(
        home: WalletActivityScreen(api: api, userId: 'user-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All activity'), findsOneWidget);
    expect(find.text('Offer payout'), findsOneWidget);
    expect(api.requestedOffsets, [0]);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(find.text('Daily bonus'), findsOneWidget);
    expect(api.requestedOffsets, [0, 1]);
  });
}
