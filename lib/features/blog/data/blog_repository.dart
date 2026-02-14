import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/features/blog/data/post_entity.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/sync/mutation_queue_entity.dart';

part 'blog_repository.g.dart';

@riverpod
BlogRepository blogRepository(BlogRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  try {
    return BlogRepository(Supabase.instance.client, db);
  } catch (e) {
    return BlogRepository(null, db);
  }
}

class BlogRepository {
  final SupabaseClient? _client;
  final AppDatabase _db;
  final List<PostEntity> _localPosts = [];

  BlogRepository(this._client, this._db);

  Future<List<PostEntity>> getPosts({required UserRole userRole}) async {
    try {
      if (_client == null) throw Exception("Offline Mode");

      final response = await _client!
          .from('blog_posts')
          .select('*, profiles(first_name, last_name, role)')
          .order('created_at', ascending: false);

      final List<dynamic> dataList = response as List<dynamic>;
      final remotePosts = dataList.map((data) {
        final profile = data['profiles'] ?? {};
        final authorName = "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''} (${profile['role'] ?? '?'})";

        return PostEntity(
          id: data['id'].toString(),
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: authorName.trim(),
          imageUrl: data['image_url'], // Nullable
          createdAt: DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now(),
        );
      }).toList();

      return [..._localPosts, ...remotePosts];

    } catch (e) {
      return [..._localPosts, ..._getDummyPosts()];
    }
  }

  // --- SEEN BY FEATURE ---
  Future<void> markPostAsSeen(String postId) async {
    if (_client == null) return;
    try {
      // Upsert view
      await _client!.from('post_views').upsert(
        {
          'post_id': int.tryParse(postId) ?? 0,
          'user_id': _client!.auth.currentUser!.id,
          'seen_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'post_id, user_id'
      );
    } catch (e) {
      debugPrint("Failed to mark post as seen: $e");
    }
  }

  Future<int> getPostViewCount(String postId) async {
    if (_client == null) return 0;
    try {
      final response = await _client!
          .from('post_views')
          .count(CountOption.exact)
          .eq('post_id', int.tryParse(postId) ?? 0);
      return response;
    } catch (e) {
      return 0;
    }
  }
  // -----------------------

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
    String? localImagePath = imageFile?.path;

    try {
      if (_client == null) throw Exception("Offline Mode");

      if (imageFile != null) {
        try {
          final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await _client!.storage.from('blog_images').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
          imageUrl = _client!.storage.from('blog_images').getPublicUrl(fileName);
        } catch (uploadError) {
          debugPrint("BlogRepository: Upload failed ($uploadError). Using local path as fallback.");
          throw Exception("Upload Failed");
        }
      }

      await _client!.from('blog_posts').insert({
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'author_id': _client!.auth.currentUser!.id,
      });

    } catch (e) {
      debugPrint("BlogRepository: Backend error ($e). Saving locally and queuing.");

      final newPost = PostEntity(
        id: "local_${DateTime.now().millisecondsSinceEpoch}",
        title: title,
        content: content,
        author: "Moi (En attente)",
        imageUrl: localImagePath,
        createdAt: DateTime.now(),
      );
      _localPosts.insert(0, newPost);

      final payload = {
        'title': title,
        'content': content,
        'image_path': localImagePath,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _db.into(_db.mutationQueue).insert(
        MutationQueueCompanion.insert(
          type: 'create_post',
          payloadJson: jsonEncode(payload),
          status: const drift.Value('pending'),
        ),
      );
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
