class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}