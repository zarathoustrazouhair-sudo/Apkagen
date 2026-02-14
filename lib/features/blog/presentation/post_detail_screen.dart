import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/features/blog/data/post_entity.dart';
import 'package:residence_lamandier_b/features/blog/data/blog_repository.dart';

// Provider to fetch view count for a specific post
final postViewCountProvider = FutureProvider.family<int, String>((ref, postId) async {
  return ref.watch(blogRepositoryProvider).getPostViewCount(postId);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger "Mark as Seen" when screen opens
    // Using simple fire-and-forget, wrapped in microtask to avoid build errors if provider accessed
    Future.microtask(() {
      ref.read(blogRepositoryProvider).markPostAsSeen(widget.post.id);
      // Refresh the count after marking (with slight delay for propagation if needed, or optimistic)
      // For now, let's just refresh the provider
      ref.invalidate(postViewCountProvider(widget.post.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewCountAsync = ref.watch(postViewCountProvider(widget.post.id));

    return Scaffold(
      backgroundColor: AppPalettes.navy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppPalettes.navy,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.post.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.black26),
                      errorWidget: (context, url, error) => Container(color: Colors.black26, child: const Icon(Icons.error)),
                    )
                  : Container(color: Colors.black26, child: const Center(child: Icon(Icons.article, size: 64, color: Colors.grey))),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppPalettes.offWhite),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: AppPalettes.gold, radius: 20, child: Icon(Icons.person, color: AppPalettes.navy)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.author, style: const TextStyle(color: AppPalettes.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(timeago.format(widget.post.createdAt), style: TextStyle(color: AppPalettes.offWhite.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      // SEEN BY ICON
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: AppPalettes.offWhite.withOpacity(0.5), size: 16),
                          const SizedBox(width: 4),
                          viewCountAsync.when(
                            data: (count) => Text("$count Vues", style: TextStyle(color: AppPalettes.offWhite.withOpacity(0.5), fontSize: 12)),
                            loading: () => SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1, color: AppPalettes.gold)),
                            error: (e, s) => Text("?", style: TextStyle(color: AppPalettes.red, fontSize: 12)),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.post.title.toUpperCase(),
                    style: const TextStyle(
                      color: AppPalettes.gold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, width: 100, color: AppPalettes.gold.withOpacity(0.5)),
                  const SizedBox(height: 24),
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      color: AppPalettes.offWhite,
                      fontSize: 16,
                      height: 1.6,
                      fontFamily: 'Lato', // Assuming Lato or default clean sans
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
