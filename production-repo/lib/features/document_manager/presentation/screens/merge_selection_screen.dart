import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/document.dart';
import '../providers/providers.dart';

class MergeSelectionScreen extends ConsumerStatefulWidget {
  const MergeSelectionScreen({super.key});

  @override
  ConsumerState<MergeSelectionScreen> createState() => _MergeSelectionScreenState();
}

class _MergeSelectionScreenState extends ConsumerState<MergeSelectionScreen> {
  final List<Document> _selectedDocuments = [];
  List<Document> _allDocuments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final getDocs = ref.read(getDocumentsUseCaseProvider);
    final result = await getDocs();
    result.fold(
      (failure) => null,
      (docs) => setState(() {
        _allDocuments = docs;
        _isLoading = false;
      }),
    );
  }

  Future<void> _onMerge() async {
    if (_selectedDocuments.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 documents to merge')),
      );
      return;
    }

    final nameController = TextEditingController(text: 'Merged_Document');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge Documents'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Output Filename'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Merge')),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final mergeUseCase = ref.read(mergeDocumentsUseCaseProvider);
      final paths = _selectedDocuments.map((d) => d.path).toList();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final result = await mergeUseCase(paths, nameController.text);

      if (mounted) navigator.pop(); // Close loading

      result.fold(
        (failure) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text('Merge failed: ${failure.message}')),
            );
          }
        },
        (document) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text('Merged successfully: ${document.name}')),
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
        title: const Text('Select PDFs to Merge'),
        actions: [
          if (_selectedDocuments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.merge_type),
              onPressed: _onMerge,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedDocuments.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Reorder for Merge (Drag to move)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _selectedDocuments.removeAt(oldIndex);
                          _selectedDocuments.insert(newIndex, item);
                        });
                      },
                      children: [
                        for (int i = 0; i < _selectedDocuments.length; i++)
                          ListTile(
                            key: ValueKey(_selectedDocuments[i].id),
                            leading: const Icon(Icons.drag_handle),
                            title: Text(_selectedDocuments[i].name),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedDocuments.removeAt(i);
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('All Documents', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: _allDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = _allDocuments[index];
                      final isSelected = _selectedDocuments.any((d) => d.id == doc.id);
                      return ListTile(
                        title: Text(doc.name),
                        subtitle: Text('${doc.pageCount} pages'),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedDocuments.add(doc);
                              } else {
                                _selectedDocuments.removeWhere((d) => d.id == doc.id);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDocuments.removeWhere((d) => d.id == doc.id);
                            } else {
                              _selectedDocuments.add(doc);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
