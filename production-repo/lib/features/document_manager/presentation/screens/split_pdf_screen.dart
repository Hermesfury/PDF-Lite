import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';
import '../../domain/entities/document.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;

class SplitPdfScreen extends ConsumerStatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  ConsumerState<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends ConsumerState<SplitPdfScreen> {
  Document? _selectedDocument;
  List<int> _selectedPages = []; // 0-indexed internally
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        body: LoadingWidget(message: 'Extracting pages...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
        actions: [
          if (_selectedDocument != null && _selectedPages.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.call_split, color: Colors.white),
              label: const Text('Extract', style: TextStyle(color: Colors.white)),
              onPressed: _performSplit,
            ),
        ],
      ),
      body: _selectedDocument == null ? _buildDocumentSelector() : _buildPageSelector(),
    );
  }

  Widget _buildDocumentSelector() {
    final docsAsync = ref.watch(getDocumentsUseCaseProvider);
    
    return FutureBuilder(
      future: docsAsync.call(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (failure) => app_error.ErrorWidget(message: failure.message),
            (documents) {
              if (documents.isEmpty) {
                return const Center(child: Text('No documents available to split.'));
              }
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(doc.name),
                    subtitle: Text('${doc.pageCount} pages'),
                    onTap: () {
                      setState(() {
                        _selectedDocument = doc;
                        _selectedPages = [];
                      });
                    },
                  );
                },
              );
            }
          );
        }
        return const Center(child: Text('Error loading documents'));
      },
    );
  }

  Widget _buildPageSelector() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Selected: ${_selectedDocument!.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () {
                setState(() {
                  _selectedDocument = null;
                  _selectedPages = [];
                });
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPages = List.generate(_selectedDocument!.pageCount, (i) => i);
                  });
                },
                child: const Text('Select All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPages.clear();
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _selectedDocument!.pageCount,
            itemBuilder: (context, index) {
              final isSelected = _selectedPages.contains(index);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPages.remove(index);
                    } else {
                      _selectedPages.add(index);
                      _selectedPages.sort();
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.insert_drive_file_outlined,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text('Page ${index + 1}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _performSplit() async {
    setState(() {
      _isProcessing = true;
    });

    final splitPdf = ref.read(splitPdfUseCaseProvider);
    final outputName = _selectedDocument!.name.replaceFirst('.pdf', '_split.pdf');
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = p.join(directory.path, outputName);

    final result = await splitPdf(
      _selectedDocument!.path,
      outputPath,
      _selectedPages,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${failure.message}')),
        );
      },
      (newDoc) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Split successfully!')),
        );
        context.pop(); // Return to home
      },
    );
  }
}
