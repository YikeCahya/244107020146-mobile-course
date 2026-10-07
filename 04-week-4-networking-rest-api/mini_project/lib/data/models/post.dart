class Post {
  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  final int userId;
  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'];
    final id = json['id'];
    final title = json['title'];
    final body = json['body'];

    return Post(
      userId: userId is num ? userId.toInt() : 0,
      id: id is num ? id.toInt() : 0,
      title: title is String ? title : '',
      body: body is String ? body : '',
    );
  }
}
