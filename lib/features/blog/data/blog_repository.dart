import 'dart:io';
import 'package:residence_lamandier_b/features/blog/data/post_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';

part 'blog_repository.g.dart';

@riverpod
BlogRepository blogRepository(BlogRepositoryRef ref) {
  return BlogRepository(Supabase.instance.client);
}

class BlogRepository {
  final SupabaseClient _client;

  BlogRepository(this._client);

  Future<List<PostEntity>> getPosts({required UserRole userRole}) async {
    // STRICT SECURITY: Concierge CANNOT see the blog
    if (userRole == UserRole.concierge) {
      throw Exception("ACCESS_DENIED: Concierge cannot access resident blog.");
    }

    try {
      final response = await _client
          .from('blog_posts')
          .select('*, profiles(first_name, last_name, role)') // Join to get author details
          .order('created_at', ascending: false);

      return (response as List).map((data) {
        final profile = data['profiles'] ?? {};
        final authorName = "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''} (${profile['role'] ?? '?'})";

        return PostEntity(
          id: data['id'].toString(),
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: authorName.trim(),
          imageUrl: data['image_url'],
          createdAt: DateTime.parse(data['created_at']),
        );
      }).toList();
    } catch (e) {
      // Return mock data if offline or error, mostly for dev
      return [];
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required UserRole userRole,
    File? imageFile,
  }) async {
    if (userRole == UserRole.concierge) {
      throw Exception("ACCESS_DENIED: Concierge cannot create posts.");
    }

    String? imageUrl;

    if (imageFile != null) {
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('blog_images').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      imageUrl = _client.storage.from('blog_images').getPublicUrl(fileName);
    }

    await _client.from('blog_posts').insert({
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'author_id': _client.auth.currentUser!.id,
    });
  }
}
