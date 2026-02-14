import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/core/theme/luxury_widgets.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/features/blog/data/blog_repository.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? result = await _compressImage(File(pickedFile.path));
      setState(() {
        _imageFile = result ?? File(pickedFile.path); // Fallback
      });
    }
  }

  // STRICT COMPRESSION PROTOCOL
  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg");

    // Initial: Quality 60, MinWidth 1024
    var compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 60,
      format: CompressFormat.jpeg,
    );

    // Size Check (Recursive degradation)
    if (compressed != null) {
      final size = await compressed.length();
      if (size > 100 * 1024) { // > 100KB
        // Try Harder: Quality 40
        final harderPath = p.join(tempDir.path, "harder_${DateTime.now().millisecondsSinceEpoch}.jpg");
        compressed = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          harderPath,
          minWidth: 1024,
          minHeight: 1024,
          quality: 40, // Reduced quality
          format: CompressFormat.jpeg,
        );
      }
      // Assuming XFile to File conversion logic if needed, but compressAndGetFile returns XFile?
      // FlutterImageCompress 2.x returns XFile?.
      if (compressed != null) {
        return File(compressed.path);
      }
    }
    return null;
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userRole = ref.read(userRoleProvider); // Get current role
      await ref.read(blogRepositoryProvider).createPost(
        title: _titleController.text,
        content: _contentController.text,
        userRole: userRole,
        imageFile: _imageFile,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post publié avec succès')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalettes.navy,
      appBar: AppBar(
        title: const Text("NOUVEAU POST", style: TextStyle(color: AppPalettes.gold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalettes.gold.withValues(alpha: 0.3)),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                ),
                child: _imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: AppPalettes.gold, size: 40),
                          SizedBox(height: 8),
                          Text("AJOUTER UNE PHOTO", style: TextStyle(color: AppPalettes.offWhite)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Fields
            LuxuryTextField(
              label: "TITRE",
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            // Replacing LuxuryTextField logic with standard if maxLines not supported,
            // but checking previous file, it used 'keyboardType: TextInputType.multiline'.
            // Assuming LuxuryTextField handles multiline if keyboardType is passed?
            // Just in case, standard TextField with styling.
            TextField(
              controller: _contentController,
              maxLines: 5,
              style: const TextStyle(color: AppPalettes.offWhite),
              decoration: InputDecoration(
                labelText: "CONTENU",
                labelStyle: TextStyle(color: AppPalettes.gold.withValues(alpha: 0.8)),
                filled: true,
                fillColor: AppPalettes.navy.withValues(alpha: 0.5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppPalettes.gold.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppPalettes.gold),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${_contentController.text.length}/10000",
                style: TextStyle(color: AppPalettes.offWhite.withValues(alpha: 0.5), fontSize: 12),
              ),
            ),

            const SizedBox(height: 32),
            GoldButton(
              label: "PUBLIER",
              isLoading: _isLoading,
              onPressed: _submitPost,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}
