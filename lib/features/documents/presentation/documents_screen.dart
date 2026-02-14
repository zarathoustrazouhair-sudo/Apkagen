import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:path/path.dart' as p;

// Structure folders
const kDocCategories = [
  "Juridique & PV",
  "Convocations AG",
  "Règlements",
  "Factures",
  "Autres"
];

final documentsProvider = FutureProvider.family<List<FileSystemEntity>, String>((ref, category) async {
  final directory = await getApplicationDocumentsDirectory();
  final targetDir = Directory(p.join(directory.path, category));

  if (!targetDir.existsSync()) {
    await targetDir.create(recursive: true);
  }

  return targetDir.listSync().where((entity) {
    return entity is File && entity.path.toLowerCase().endsWith('.pdf');
  }).toList();
});

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _selectedCategory = "Juridique & PV";

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsProvider(_selectedCategory));

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
            onPressed: () => ref.refresh(documentsProvider(_selectedCategory)),
          ),
        ],
      ),
      body: Column(
        children: [
          // CATEGORY TABS (Horizontal Scroll)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: kDocCategories.length,
              itemBuilder: (context, index) {
                final category = kDocCategories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(category, style: TextStyle(color: isSelected ? AppTheme.darkNavy : AppTheme.offWhite, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: AppTheme.gold,
                    backgroundColor: AppTheme.darkNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = category);
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white10),

          // FILE LIST
          Expanded(
            child: docsAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text("Dossier '$_selectedCategory' vide.", style: const TextStyle(color: Colors.grey)),
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
                            style: TextStyle(color: AppTheme.offWhite.withValues(alpha: 0.5), fontSize: 10),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // Allow Syndic to upload (Mock logic)
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload PDF (Mock) vers dossier courant...")));
           // Ideally: Pick file -> Copy to getApplicationDocumentsDirectory() / _selectedCategory / name
        },
        backgroundColor: AppTheme.gold,
        child: const Icon(Icons.upload_file, color: AppTheme.darkNavy),
      ),
    );
  }
}
