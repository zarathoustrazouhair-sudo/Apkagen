import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/core/theme/luxury_widgets.dart';
import 'package:residence_lamandier_b/features/blog/data/post_entity.dart';
import 'package:residence_lamandier_b/features/blog/data/blog_repository.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/features/blog/presentation/create_post_screen.dart';
import 'package:residence_lamandier_b/features/blog/presentation/post_detail_screen.dart';

class BlogFeedScreen extends ConsumerWidget {
  const BlogFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);

    // STRICT RULE: Concierge CANNOT ACCESS
    if (userRole == UserRole.concierge) {
      return Scaffold(
        backgroundColor: AppPalettes.navy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: AppPalettes.red.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text("ACCÈS RÉSERVÉ AUX RÉSIDENTS", style: TextStyle(color: AppPalettes.offWhite, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final postsAsync = ref.watch(blogPostsProvider(userRole));

    return Scaffold(
      backgroundColor: AppPalettes.navy,
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) return const Center(child: Text("Aucun article.", style: TextStyle(color: Colors.white)));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildPostCard(context, ref, post, userRole),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppPalettes.gold)),
        error: (err, stack) => Center(child: Text("Erreur: $err", style: const TextStyle(color: AppPalettes.red))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        backgroundColor: AppPalettes.gold,
        child: const Icon(Icons.add, color: AppPalettes.navy),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, WidgetRef ref, PostEntity post, UserRole userRole) {
    // MODERATION: Syndic can delete ANY post. Author (not strictly checked here without ID, assuming Syndic for now)
    final canDelete = userRole == UserRole.syndic;

    return LuxuryCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: AppPalettes.gold, radius: 16, child: Icon(Icons.person, size: 16, color: AppPalettes.navy)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: const TextStyle(color: AppPalettes.offWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(timeago.format(post.createdAt), style: TextStyle(color: AppPalettes.offWhite.withValues(alpha: 0.5), fontSize: 10)),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppPalettes.navy,
                          title: const Text("Supprimer ?", style: TextStyle(color: Colors.white)),
                          content: const Text("Cette action est irréversible.", style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ANNULER")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("SUPPRIMER", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(blogRepositoryProvider).deletePost(post.id);
                        ref.invalidate(blogPostsProvider); // Refresh list
                      }
                    },
                  ),
              ],
            ),
          ),
          // Image
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(height: 250, color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => Container(height: 250, color: Colors.black26, child: const Icon(Icons.error)),
            )
          else
             Container(height: 150, color: Colors.black26, child: const Center(child: Icon(Icons.article, size: 48, color: Colors.grey))),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.toUpperCase(),
                  style: const TextStyle(
                    color: AppPalettes.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppPalettes.offWhite, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                GoldButton(
                  label: "LIRE LA SUITE",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple provider wrapper for fetching posts
final blogPostsProvider = FutureProvider.family<List<PostEntity>, UserRole>((ref, role) async {
  return ref.watch(blogRepositoryProvider).getPosts(userRole: role);
});
