import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../domain/entities/document.dart';
import '../providers/providers.dart';

/// Screen showing document details
class DocumentDetailScreen extends ConsumerStatefulWidget {
  final String documentId;

  const DocumentDetailScreen({
    super.key,
    required this.documentId,
  });

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _isLoading = true;
  Document? _document;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get document from repository
    final repository = ref.read(documentRepositoryProvider);
    final result = await repository.getDocument(widget.documentId);

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (document) {
        setState(() {
          _document = document;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _deleteDocument() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Move "${_document?.name}" to trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deleteDocument = ref.read(deleteDocumentUseCaseProvider);
      await deleteDocument(widget.documentId);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_document?.name ?? 'Document'),
        actions: [
          IconButton(
            icon: Icon(
              _document?.isFavorite == true ? Icons.star : Icons.star_border,
              color: _document?.isFavorite == true ? Colors.amber : null,
            ),
            onPressed: _document != null
                ? () async {
                    final toggleFavorite = ref.read(toggleFavoriteUseCaseProvider);
                    await toggleFavorite(widget.documentId);
                    _loadDocument();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _document != null ? _deleteDocument : null,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading document...');
    }

    if (_errorMessage != null) {
      return app_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadDocument,
      );
    }

    if (_document == null) {
      return const app_error.ErrorWidget(
        message: 'Document not found',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document icon
          Center(
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Document info
          _buildInfoRow('Name', _document!.name),
          _buildInfoRow('Pages', _document!.pageCount.toString()),
          _buildInfoRow('Size', _formatSize(_document!.sizeBytes)),
          _buildInfoRow('Added', _formatDate(_document!.dateAdded)),
          _buildInfoRow('Modified', _formatDate(_document!.dateModified)),
          if (_document!.lastOpened != null)
            _buildInfoRow('Last Opened', _formatDate(_document!.lastOpened!)),
          if (_document!.lastPageRead != null)
            _buildInfoRow('Last Page', '${_document!.lastPageRead! + 1}'),
          
          const SizedBox(height: 32),
          
          // Open button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/viewer/${widget.documentId}'),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open PDF'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
