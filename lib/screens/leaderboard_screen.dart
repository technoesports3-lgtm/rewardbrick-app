import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/leaderboard_entry.dart';
import '../services/api_service.dart';
import '../theme_design_system.dart';

class LeaderboardScreen extends StatefulWidget {
  final String userId;

  const LeaderboardScreen({super.key, required this.userId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const _pageSize = 50;

  final ApiService _api = ApiService();
  List<LeaderboardEntry> _entries = const [];
  int? _currentUserRank;
  int? _currentUserCoins;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _api.getLeaderboard(
        widget.userId,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _entries = page.entries;
        _currentUserRank = page.currentUserRank;
        _currentUserCoins = page.currentUserCoins;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ApiRequestException
            ? error.message
            : 'Could not load the leaderboard. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _error = null;
    });
    try {
      final page = await _api.getLeaderboard(
        widget.userId,
        limit: _pageSize,
        offset: _entries.length,
      );
      if (!mounted) return;
      setState(() {
        _entries = [..._entries, ...page.entries];
        _currentUserRank = page.currentUserRank;
        _currentUserCoins = page.currentUserCoins;
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ApiRequestException
            ? error.message
            : 'Could not load more leaderboard entries.';
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: bgLight,
        foregroundColor: textDark,
        elevation: 0,
      ),
      backgroundColor: bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryDarkBlue,
          onRefresh: _loadFirstPage,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Ranked by lifetime coins earned',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textDark.withValues(alpha: .62),
                ),
              ),
              const SizedBox(height: 14),
              if (_currentUserRank != null)
                _currentUserCard(_currentUserRank!, _currentUserCoins ?? 0),
              if (_currentUserRank != null) const SizedBox(height: 16),
              if (_loading && _entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 72),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null && _entries.isEmpty)
                _errorCard()
              else if (_entries.isEmpty)
                _emptyCard()
              else ...[
                _topPerformerCard(_entries.first),
                const SizedBox(height: 18),
                ..._entries.map(_leaderboardRow),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                if (_loadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_hasMore)
                  Center(
                    child: TextButton(
                      onPressed: _loadMore,
                      child: const Text('Load more'),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'You are all caught up.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textDark.withValues(alpha: .6),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentUserCard(int rank, int coins) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE7F6FC), Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDAE9F7),
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.person_pin_circle_rounded,
                color: primaryDarkBlue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your rank',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textDark.withValues(alpha: .65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '#$rank',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$coins coins',
              style: GoogleFonts.poppins(
                color: accentCoral,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _topPerformerCard(LeaderboardEntry topPerformer) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFBFE4F6),
              offset: Offset(8, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            _podiumBadge('🥇'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top performer',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textDark.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    topPerformer.isCurrentUser ? 'You' : topPerformer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  Text(
                    '${topPerformer.coinsEarned} coins',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: accentCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _leaderboardRow(LeaderboardEntry entry) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: entry.isCurrentUser
              ? const Color(0xFFE7F6FC)
              : entry.rank == 1
                  ? const Color(0xFFFFF4E5)
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDAE9F7),
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: entry.rank == 1
                    ? accentCoral
                    : entry.rank == 2
                        ? primaryDarkBlue
                        : entry.rank == 3
                            ? primarySkyBlue
                            : const Color(0xFFE8EEF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: entry.rank <= 3 ? Colors.white : textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.isCurrentUser ? 'You' : entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ),
            Text(
              '${entry.coinsEarned} coins',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: accentCoral,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  Widget _errorCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              _error ?? 'Could not load the leaderboard.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: textDark),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadFirstPage,
              child: const Text('Try again'),
            ),
          ],
        ),
      );

  Widget _emptyCard() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'No leaderboard entries yet.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: textDark),
        ),
      );

  Widget _podiumBadge(String emoji) => Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: accentCoral,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
      );
}
