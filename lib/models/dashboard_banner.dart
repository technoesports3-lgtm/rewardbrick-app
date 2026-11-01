class DashboardBanner {
  final int id;
  final String title;
  final String subtitle;
  final String iconName;
  final String accentColor;
  final String imageUrl;
  final String targetUrl;

  const DashboardBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.accentColor,
    required this.imageUrl,
    required this.targetUrl,
  });

  factory DashboardBanner.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final subtitle = json['subtitle'];
    final iconName = json['icon_name'];
    final accentColor = json['accent_color'];
    final imageUrl = json['image_url'] ?? '';
    final targetUrl = json['target_url'] ?? '';
    if ((id is! int && id is! num) ||
        title is! String ||
        subtitle is! String ||
        iconName is! String ||
        accentColor is! String ||
        imageUrl is! String ||
        targetUrl is! String ||
        !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(accentColor)) {
      throw const FormatException('Invalid dashboard card.');
    }
    return DashboardBanner(
      id: (id as num).toInt(),
      title: title,
      subtitle: subtitle,
      iconName: iconName,
      accentColor: accentColor,
      imageUrl: imageUrl,
      targetUrl: targetUrl,
    );
  }
}
