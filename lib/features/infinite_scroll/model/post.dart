// models/post.dart
class PostModel {
  final int id;
  final String title;
  final String body;

  PostModel({required this.id, required this.title, required this.body});

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      PostModel(id: json['id'], title: json['title'], body: json['body']);

  @override
  String toString() {
    return 'Post{id: $id, title: $title, body: $body}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final PostModel otherPost = other as PostModel;
    return id == otherPost.id;
  }

  @override
  int get hashCode => id.hashCode;
}
