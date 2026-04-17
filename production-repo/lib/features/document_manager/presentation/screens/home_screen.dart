import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/document.dart';
import '../providers/providers.dart';
import '../../../../main.dart';

/// Home screen showing document list
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;
  List<Document> _documents = [];
  String? _errorMessage;
  String _searchQuery = '';
  String? _activeTag;
  bool _isGridView = true;
  bool _isFolderView = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final getDocuments = ref.read(getDocumentsUseCaseProvider);
    final result = await getDocuments(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (documents) async {
        setState(() {
          _documents = documents;
          _isLoading = false;
        });
        
        // Background repair for 0MB documents
        for (final doc in documents) {
          if (doc.sizeBytes == 0 || doc.pageCount == 0) {
            _repairMetadata(doc);
          }
        }
      },
    );
  }

  Future<void> _repairMetadata(Document doc) async {
    try {
      final repo = ref.read(documentRepositoryProvider);
      final size = await File(doc.path).length();
      
      int pages = 0;
      try {
        final List<int> bytes = await File(doc.path).readAsBytes();
        final sf.PdfDocument pdfDoc = sf.PdfDocument(inputBytes: bytes);
        pages = pdfDoc.pages.count;
        pdfDoc.dispose();
      } catch (_) {}

      if (size != doc.sizeBytes || pages != doc.pageCount) {
        final updated = doc.copyWith(sizeBytes: size, pageCount: pages);
        await repo.updateDocument(updated);
        // Silent update, don't trigger full reload to avoid loops
      }
    } catch (_) {}
  }

  Future<void> _importDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        if (file.path != null) {
          final importDocument = ref.read(importDocumentUseCaseProvider);
          final importResult = await importDocument(file.path!);

          importResult.fold(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to import: ${failure.message}')),
                );
              }
            },
            (document) {
              _loadDocuments();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Imported: ${document.name}')),
                );
              }
            },
          );
        } else {
          throw Exception('Could not get file path');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Document document) async {
    final toggleFavorite = ref.read(toggleFavoriteUseCaseProvider);
    await toggleFavorite(document.id);
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Lite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_outlined),
            tooltip: 'PDF Tools',
            onPressed: () => _showToolsMenu(context),
          ),
          IconButton(
            icon: Icon(_isFolderView ? Icons.folder : Icons.folder_open),
            tooltip: 'Toggle Folder View',
            onPressed: () {
              setState(() {
                _isFolderView = !_isFolderView;
                if (_isFolderView) {
                  _activeTag = null; // Clear filter when entering folder view
                }
              });
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/PDF Lite.png', width: 40, height: 40),
                    SizedBox(height: 10),
                    Text('PDF Lite', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
            ),
            Consumer(builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: mode == ThemeMode.dark,
                onChanged: (val) => ref.read(themeModeProvider.notifier).state = 
                  val ? ThemeMode.dark : ThemeMode.light,
              );
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadDocuments();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) => _loadDocuments(),
            ),
          ),
          
          // Tag Filters
          if (_documents.any((d) => d.tags.isNotEmpty))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _activeTag == null,
                    onSelected: (_) => setState(() => _activeTag = null),
                  ),
                  const SizedBox(width: 8),
                  ..._documents.expand((d) => d.tags).toSet().map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(tag),
                        selected: _activeTag == tag,
                        onSelected: (_) => setState(() => _activeTag = tag),
                      ),
                    );
                  }),
                ],
              ),
            ),
          
          // Document list
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importDocument,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading documents...');
    }

    if (_errorMessage != null) {
      return app_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadDocuments,
      );
    }

    if (_documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/PDF Lite.png', width: 80, height: 80),
              const SizedBox(height: 24),
              Text(
                'No Documents',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to import your first PDF',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _importDocument,
                icon: const Icon(Icons.add),
                label: const Text('Import PDF'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: _isFolderView 
          ? _buildFolderView() 
          : (_isGridView ? _buildGridView() : _buildListView()),
    );
  }

  Widget _buildFolderView() {
    final tags = _documents
        .expand((d) => d.tags)
        .toSet()
        .toList();
    
    // Add "Uncategorized" if there are docs without tags
    final hasUncategorized = _documents.any((d) => d.tags.isEmpty);
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tags.length + (hasUncategorized ? 1 : 0),
      itemBuilder: (context, index) {
        if (hasUncategorized && index == tags.length) {
          return _buildFolderItem('Uncategorized', Icons.folder_open_outlined);
        }
        return _buildFolderItem(tags[index], Icons.folder);
      },
    );
  }

  Widget _buildFolderItem(String title, IconData icon) {
    final count = title == 'Uncategorized'
        ? _documents.where((d) => d.tags.isEmpty).length
        : _documents.where((d) => d.tags.contains(title)).length;

    return InkWell(
      onTap: () {
        setState(() {
          _activeTag = title == 'Uncategorized' ? null : title;
          _isFolderView = false;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$count files',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    final filteredDocs = _activeTag == null 
        ? _documents 
        : _documents.where((d) => d.tags.contains(_activeTag)).toList();
        
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final document = filteredDocs[index];
        return _buildGridItem(document);
      },
    );
  }

  Widget _buildListView() {
    final filteredDocs = _activeTag == null 
        ? _documents 
        : _documents.where((d) => d.tags.contains(_activeTag)).toList();
        
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final document = filteredDocs[index];
        return _buildListItem(document);
      },
    );
  }

  Widget _buildGridItem(Document document) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/viewer/${document.id}'),
        onLongPress: () => _showDocumentContextMenu(document),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(document.sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB • ${document.pageCount} pages',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(Document document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.picture_as_pdf,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          document.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${(document.sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB • ${document.pageCount} pages',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showRenameDialog(document),
            ),
            IconButton(
              icon: Icon(
                document.isFavorite ? Icons.star : Icons.star_border,
                color: document.isFavorite ? Colors.amber : null,
              ),
              onPressed: () => _toggleFavorite(document),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(document),
            ),
          ],
        ),
        onTap: () => context.push('/viewer/${document.id}'),
        onLongPress: () => _showDocumentContextMenu(document),
      ),
    );
  }

  void _showRenameDialog(Document document) {
    final controller = TextEditingController(text: p.basenameWithoutExtension(document.name));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
            hintText: 'Enter new name...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                final newName = '${controller.text}.pdf';
                final renameUseCase = ref.read(renameDocumentUseCaseProvider);
                final result = await renameUseCase(document.id, newName);
                
                if (!mounted) return;
                
                navigator.pop();
                result.fold(
                  (failure) => messenger.showSnackBar(
                    SnackBar(content: Text('Rename failed: ${failure.message}')),
                  ),
                  (updated) {
                    _loadDocuments();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Document renamed successfully')),
                    );
                  },
                );
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Document document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to move "${document.name}" to trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deleteDocument = ref.read(deleteDocumentUseCaseProvider);
      await deleteDocument(document.id);
      _loadDocuments();
    }
  }

  Future<void> _showTagEditor(Document document) async {
    final textController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Tags'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    children: document.tags.map((tag) => InputChip(
                      label: Text(tag),
                      onDeleted: () async {
                        final newTags = List<String>.from(document.tags)..remove(tag);
                        final updatedDoc = document.copyWith(tags: newTags, dateModified: DateTime.now());
                        await ref.read(documentRepositoryProvider).updateDocument(updatedDoc);
                        setDialogState(() {
                          document = updatedDoc;
                        });
                        _loadDocuments();
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: const InputDecoration(hintText: 'New tag...'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          if (textController.text.isNotEmpty) {
                            final newTags = List<String>.from(document.tags)..add(textController.text.trim());
                            final updatedDoc = document.copyWith(tags: newTags.toSet().toList(), dateModified: DateTime.now());
                            await ref.read(documentRepositoryProvider).updateDocument(updatedDoc);
                            setDialogState(() {
                              document = updatedDoc;
                            });
                            textController.clear();
                            _loadDocuments();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showToolsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PDF Power Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolItem(
                    context,
                    icon: Icons.merge_type,
                    label: 'Merge PDFs',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/merge');
                    },
                  ),
                  _buildToolItem(
                    context,
                    icon: Icons.image_search,
                    label: 'Image to PDF',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/image-to-pdf');
                    },
                  ),
                  _buildToolItem(
                    context,
                    icon: Icons.call_split,
                    label: 'Split PDF',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/split-pdf');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDocumentContextMenu(Document document) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(document);
              },
            ),
            ListTile(
              leading: Icon(
                document.isFavorite ? Icons.star : Icons.star_border,
                color: document.isFavorite ? Colors.amber : null,
              ),
              title: Text(document.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share PDF'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await Share.shareXFiles(
                    [XFile(document.path as String)],
                    text: document.name,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to share PDF: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(document);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
