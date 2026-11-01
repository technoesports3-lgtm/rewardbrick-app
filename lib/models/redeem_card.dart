class RedeemCard {
  final int id;
  final String title;
  final int denominationInr;
  final int coinsRequired;
  final int minimumCoins;

  const RedeemCard({
    required this.id,
    required this.title,
    required this.denominationInr,
    required this.coinsRequired,
    required this.minimumCoins,
  });

  factory RedeemCard.fromJson(Map<String, dynamic> json) {
    int? integerValue(dynamic value) {
      if (value is int) return value;
      if (value is num && value.isFinite) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    final id = integerValue(json['id']);
    final title = json['title'];
    final denomination = integerValue(json['denomination_inr']);
    final coinsRequired = integerValue(json['coins_required']);
    final minimumCoins = integerValue(json['minimum_coins']);
    if (id == null ||
        title is! String ||
        denomination == null ||
        coinsRequired == null ||
        minimumCoins == null) {
      throw const FormatException('Invalid redemption card.');
    }
    if (denomination < 25 ||
        coinsRequired != denomination * 10 ||
        minimumCoins < coinsRequired) {
      throw const FormatException('Invalid redemption card.');
    }
    return RedeemCard(
      id: id,
      title: title,
      denominationInr: denomination,
      coinsRequired: coinsRequired,
      minimumCoins: minimumCoins,
    );
  }
}
