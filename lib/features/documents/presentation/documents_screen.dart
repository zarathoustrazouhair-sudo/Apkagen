import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';

final documentsProvider = FutureProvider<List<FileSystemEntity>>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  // List all files, filtering for PDF or relevant types if needed
  if (!directory.existsSync()) return [];

  return directory.listSync().where((entity) {
    return entity is File && entity.path.toLowerCase().endsWith('.pdf');
  }).toList();
});

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("DOCUMENTS", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.gold),
            onPressed: () => ref.refresh(documentsProvider),
          ),
        ],
      ),
      body: docsAsync.when(
        data: (files) {
          if (files.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Aucun document généré.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final name = file.path.split(Platform.pathSeparator).last;
              final stat = file.statSync();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LuxuryCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    title: Text(name, style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${stat.modified.day}/${stat.modified.month}/${stat.modified.year} - ${(stat.size / 1024).toStringAsFixed(1)} KB",
                      style: TextStyle(color: AppTheme.offWhite.withOpacity(0.5), fontSize: 10),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new, color: AppTheme.gold),
                      onPressed: () {
                        OpenFile.open(file.path);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur: $err", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
