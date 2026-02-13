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
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(tempDir.path, "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg");

      // Compress Image (Max 1920x1080, 85%) and write directly to file
      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        minWidth: 1920,
        minHeight: 1080,
        quality: 85,
      );

      setState(() {
        if (compressedXFile != null) {
          _imageFile = File(compressedXFile.path);
        } else {
          // Fallback to original if compression fails
          _imageFile = File(pickedFile.path);
        }
      });
    }
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
                  border: Border.all(color: AppPalettes.gold.withOpacity(0.3)),
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
            LuxuryTextField(
              label: "CONTENU",
              controller: _contentController,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${_contentController.text.length}/10000",
                style: TextStyle(color: AppPalettes.offWhite.withOpacity(0.5), fontSize: 12),
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
