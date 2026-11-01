class AffiliatePost {
  final int id;
  final String title;
  final String message;
  final String imageUrl;
  final String destinationUrl;

  const AffiliatePost({
    required this.id,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.destinationUrl,
  });

  factory AffiliatePost.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final message = json['message'];
    final imageUrl = json['image_url'] ?? '';
    final destinationUrl = json['destination_url'];
    if ((id is! int && id is! num) ||
        title is! String ||
        message is! String ||
        imageUrl is! String ||
        destinationUrl is! String ||
        Uri.tryParse(destinationUrl)?.scheme != 'https') {
      throw const FormatException('Invalid affiliate post.');
    }
    return AffiliatePost(
      id: (id as num).toInt(),
      title: title,
      message: message,
      imageUrl: imageUrl,
      destinationUrl: destinationUrl,
    );
  }
}
