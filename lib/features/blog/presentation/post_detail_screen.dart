import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/features/blog/data/post_entity.dart';

class PostDetailScreen extends StatelessWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalettes.navy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppPalettes.navy,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: post.imageUrl != null && post.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: post.imageUrl!,
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
                          Text(post.author, style: const TextStyle(color: AppPalettes.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(timeago.format(post.createdAt), style: TextStyle(color: AppPalettes.offWhite.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    post.title.toUpperCase(),
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
                    post.content,
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
