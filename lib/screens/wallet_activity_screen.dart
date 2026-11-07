import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme_design_system.dart';

class WalletActivityScreen extends StatefulWidget {
  final ApiService api;
  final String userId;

  const WalletActivityScreen({
    super.key,
    required this.api,
    required this.userId,
  });

  @override
  State<WalletActivityScreen> createState() => _WalletActivityScreenState();
}

class _WalletActivityScreenState extends State<WalletActivityScreen> {
  static const _pageSize = 30;

  final List<dynamic> _activity = [];
  int _offset = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity({bool refresh = false}) async {
    if (_loading || (!_hasMore && !refresh)) return;
    setState(() {
      _loading = true;
      _error = null;
      if (refresh) {
        _activity.clear();
        _offset = 0;
        _hasMore = true;
      }
    });

    try {
      final result = await widget.api.getWalletActivity(
        widget.userId,
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      final items = result['activity'] as List<dynamic>;
      setState(() {
        _activity.addAll(items);
        _offset += items.length;
        _hasMore = result['has_more'] as bool;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiRequestException
            ? error.message
            : 'Could not load wallet activity. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text('All activity'),
        backgroundColor: bgLight,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: primaryDarkBlue,
        onRefresh: () => _loadActivity(refresh: true),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_activity.isEmpty && _loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_activity.isEmpty && _error != null)
              _messageState(_error!, retry: true)
            else if (_activity.isEmpty)
              _messageState('Your wallet transactions will appear here.')
            else ...[
              for (final item in _activity) _activityTile(item),
              if (_error != null) _messageState(_error!, retry: true),
              if (_hasMore && _error == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: OutlinedButton(
                      onPressed: _loading ? null : _loadActivity,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load more'),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _activityTile(dynamic item) {
    final data = item is Map ? item : <dynamic, dynamic>{};
    final activityType = (data['activity_type'] ?? '').toString();
    final amount = num.tryParse('${data['amount_coins'] ?? 0}') ?? 0;
    final rawTitle = (data['title'] ?? 'Wallet activity').toString();
    final rawStatus = (data['status'] ?? '').toString();
    final voucher = data['voucher_reference'];
    final status = voucher is String && voucher.isNotEmpty
        ? '$rawStatus · Voucher: $voucher'
        : rawStatus.replaceAll('_', ' ');
    final dateValue = DateTime.tryParse('${data['created_at'] ?? ''}');
    final dateLabel = dateValue == null
        ? ''
        : '${dateValue.toLocal().day.toString().padLeft(2, '0')}/'
            '${dateValue.toLocal().month.toString().padLeft(2, '0')}/'
            '${dateValue.toLocal().year}';
    final isCredit = amount > 0;
    final isWithdrawal = activityType == 'withdrawal';
    final icon =
        isWithdrawal ? Icons.card_giftcard_rounded : Icons.swap_vert_rounded;
    final color = isCredit ? successGreen : accentCoral;
    final amountLabel =
        '${isCredit ? '+' : ''}${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)} coins';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rawTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  [status, dateLabel]
                      .where((value) => value.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(color: textMedium, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _messageState(String message, {bool retry = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 18),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 42, color: textMedium),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (retry) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _loadActivity(refresh: _activity.isNotEmpty),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      );
}
