class PostEntity {
  final String id;
  final String title;
  final String content;
  final String author;
  final String? imageUrl;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.imageUrl,
    required this.createdAt,
  });
}
