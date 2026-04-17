import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as app_error;
import '../../../document_manager/domain/entities/document.dart';
import '../../../document_manager/presentation/providers/providers.dart';

/// Screen for viewing PDF documents
class PdfViewerScreen extends ConsumerStatefulWidget {
  final String documentId;

  const PdfViewerScreen({
    super.key,
    required this.documentId,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  PdfViewerController? _pdfController;
  Document? _document;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  final List<Annotation> _addedAnnotations = [];

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

    final repository = ref.read(documentRepositoryProvider);
    final result = await repository.getDocument(widget.documentId);

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (document) async {
        setState(() {
          _document = document;
        });

        try {
          // Check if file exists before initializing controller
          final file = File(document.path as String);
          if (!await file.exists()) {
            setState(() {
              _errorMessage = 'PDF file not found: ${document.path}';
              _isLoading = false;
            });
            return;
          }

          _pdfController = PdfViewerController();

          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to load PDF: $e';
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading PDF...');
    }

    if (_errorMessage != null) {
      return app_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadDocument,
        icon: Icons.error_outline,
      );
    }

    if (_pdfController == null) {
      return const app_error.ErrorWidget(
        message: 'Failed to initialize PDF viewer',
        icon: Icons.error_outline,
      );
    }

    return Stack(
      children: [
        // PDF View
        GestureDetector(
          onTap: () {
            // Toggle controls if needed, but simplified
          },
          child: SfPdfViewer.file(
            File(_document!.path as String),
            controller: _pdfController,
            onPageChanged: _onPageChanged,
            enableTextSelection: true,
            onDocumentLoaded: (details) {
              setState(() {
                _totalPages = details.document.pages.count;
              });
            },
            onTextSelectionChanged: (details) {
              if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: details.selectedText!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Text copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ),

        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    _document?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () async {
                    if (_document?.path != null) {
                      await Share.shareXFiles(
                        [XFile(_document!.path as String)],
                        text: _document!.name,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // Bottom bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              top: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),


      ],
    );
  }
}