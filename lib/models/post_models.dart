class PostModel {
  final String id;
  final String userId;
  final String? statusText;
  final String? imageUrl;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    this.statusText,
    this.imageUrl,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      statusText: json['status_text'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}