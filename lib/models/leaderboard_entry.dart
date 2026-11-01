class LeaderboardEntry {
  final int rank;
  final String name;
  final int coinsEarned;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.coinsEarned,
    required this.isCurrentUser,
  });
}

class LeaderboardPage {
  final List<LeaderboardEntry> entries;
  final int? currentUserRank;
  final int? currentUserCoins;
  final int totalUsers;
  final bool hasMore;

  const LeaderboardPage({
    required this.entries,
    required this.currentUserRank,
    required this.currentUserCoins,
    required this.totalUsers,
    required this.hasMore,
  });
}
