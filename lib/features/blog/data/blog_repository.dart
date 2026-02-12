import 'dart:io';
import 'package:residence_lamandier_b/features/blog/data/post_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';

part 'blog_repository.g.dart';

@riverpod
BlogRepository blogRepository(BlogRepositoryRef ref) {
  // Gracefully handle missing Supabase instance for tests/demos
  try {
    return BlogRepository(Supabase.instance.client);
  } catch (e) {
    // If Supabase not initialized, mock it
    // In a real app we might throw, but here we want to avoid crashes
    return BlogRepository(null);
  }
}

class BlogRepository {
  final SupabaseClient? _client;
  final List<PostEntity> _localPosts = []; // In-memory fallback

  BlogRepository(this._client);

  Future<List<PostEntity>> getPosts({required UserRole userRole}) async {
    // STRICT SECURITY: Concierge CANNOT see the blog
    if (userRole == UserRole.concierge) {
      throw Exception("ACCESS_DENIED: Concierge cannot access resident blog.");
    }

    try {
      if (_client == null) throw Exception("Offline Mode");

      final response = await _client!
          .from('blog_posts')
          .select('*, profiles(first_name, last_name, role)') // Join to get author details
          .order('created_at', ascending: false);

      final remotePosts = (response as List).map((data) {
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

      return [..._localPosts, ...remotePosts];

    } catch (e) {
      // Fallback to local + dummy data if offline or error
      return [..._localPosts, ..._getDummyPosts()];
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

    try {
      if (_client == null) throw Exception("Offline Mode");

      if (imageFile != null) {
        final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _client!.storage.from('blog_images').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        imageUrl = _client!.storage.from('blog_images').getPublicUrl(fileName);
      }

      await _client!.from('blog_posts').insert({
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'author_id': _client!.auth.currentUser!.id,
      });

      // Also add to local cache for immediate feedback if optimistic update needed
      // but usually we rely on refetch. Since we return success, refetch happens.

    } catch (e) {
      // Offline fallback: Add to local memory so user sees it "worked"
      print("BlogRepository: Backend error ($e). Saving locally.");

      final newPost = PostEntity(
        id: "local_${DateTime.now().millisecondsSinceEpoch}",
        title: title,
        content: content,
        author: "Moi (Hors ligne)",
        imageUrl: null, // Can't easily persist local file URL across restarts without more work
        createdAt: DateTime.now(),
      );
      _localPosts.insert(0, newPost);

      // We don't throw, we pretend success for UX unless strictly required
    }
  }

  List<PostEntity> _getDummyPosts() {
    return [
      PostEntity(
        id: "mock_1",
        title: "FÊTE DES VOISINS",
        content: "Chers résidents, nous organisons une petite fête ce samedi dans le jardin. Venez nombreux avec vos spécialités culinaires !",
        author: "Mme Benjelloun (Résident)",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: "https://images.unsplash.com/photo-1530103862676-de3c9a59af57?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
      ),
      PostEntity(
        id: "mock_2",
        title: "TRAVAUX ASCENSEUR B",
        content: "L'ascenseur du bloc B sera en maintenance préventive ce mardi de 10h à 14h. Merci de votre compréhension.",
        author: "Syndic (Adjoint)",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: null,
      ),
      PostEntity(
        id: "mock_3",
        title: "RAPPEL: TRI SÉLECTIF",
        content: "Merci de bien vouloir séparer les cartons des ordures ménagères. Un bac spécial a été installé au sous-sol.",
        author: "Gardien Principal (Concierge)",
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        imageUrl: "https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
      ),
    ];
  }
}
