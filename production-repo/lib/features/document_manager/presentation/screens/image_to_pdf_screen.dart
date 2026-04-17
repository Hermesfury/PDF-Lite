import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';

class ImageToPdfSelectionScreen extends ConsumerStatefulWidget {
  const ImageToPdfSelectionScreen({super.key});

  @override
  ConsumerState<ImageToPdfSelectionScreen> createState() => _ImageToPdfSelectionScreenState();
}

class _ImageToPdfSelectionScreenState extends ConsumerState<ImageToPdfSelectionScreen> {
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _onConvert() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    final nameController = TextEditingController(text: 'Images_to_PDF');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to PDF'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Output Filename'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Convert')),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final convertUseCase = ref.read(convertImagesToPdfUseCaseProvider);
      final paths = _selectedImages.map((img) => img.path).toList();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final result = await convertUseCase(paths, nameController.text);

      if (mounted) navigator.pop(); // Close loading

      result.fold(
        (failure) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text('Conversion failed: ${failure.message}')),
            );
          }
        },
        (document) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text('Converted successfully: ${document.name}')),
            );
            context.go('/');
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _onConvert,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Select Images'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          if (_selectedImages.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Reorder Images (Drag to move)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _selectedImages.removeAt(oldIndex);
                    _selectedImages.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < _selectedImages.length; i++)
                    Card(
                      key: ValueKey(_selectedImages[i].path),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(_selectedImages[i].path),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(p.basename(_selectedImages[i].path)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.drag_handle),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: Text('No images selected'),
              ),
            ),
        ],
      ),
    );
  }
}
