import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/document_local_datasource.dart';
import '../../data/datasources/file_datasource.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/usecases/document_usecases.dart';
import '../../domain/services/pdf_processor.dart';
import '../../data/services/pdf_processor_impl.dart';

/// Provider for local data source - platform aware
final documentLocalDataSourceProvider = Provider<DocumentLocalDataSource>((ref) {
  return DocumentLocalDataSourceImpl();
});

/// Provider for file data source - platform aware
final fileDataSourceProvider = Provider<FileDataSource>((ref) {
  return FileDataSourceImpl();
});

/// Provider for document repository
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(
    localDataSource: ref.watch(documentLocalDataSourceProvider),
    fileDataSource: ref.watch(fileDataSourceProvider),
  );
});

/// Provider for get documents use case
final getDocumentsUseCaseProvider = Provider<GetDocuments>((ref) {
  return GetDocuments(ref.watch(documentRepositoryProvider));
});

/// Provider for import document use case
final importDocumentUseCaseProvider = Provider<ImportDocument>((ref) {
  return ImportDocument(ref.watch(documentRepositoryProvider));
});

/// Provider for delete document use case
final deleteDocumentUseCaseProvider = Provider<DeleteDocument>((ref) {
  return DeleteDocument(ref.watch(documentRepositoryProvider));
});

/// Provider for toggle favorite use case
final toggleFavoriteUseCaseProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(documentRepositoryProvider));
});

/// Provider for update last page use case
final updateLastPageUseCaseProvider = Provider<UpdateLastPage>((ref) {
  return UpdateLastPage(ref.watch(documentRepositoryProvider));
});

/// Provider for get trash documents use case
final getTrashDocumentsUseCaseProvider = Provider<GetTrashDocuments>((ref) {
  return GetTrashDocuments(ref.watch(documentRepositoryProvider));
});

/// Provider for restore document use case
final restoreDocumentUseCaseProvider = Provider<RestoreDocument>((ref) {
  return RestoreDocument(ref.watch(documentRepositoryProvider));
});

/// Provider for empty trash use case
final emptyTrashUseCaseProvider = Provider<EmptyTrash>((ref) {
  return EmptyTrash(ref.watch(documentRepositoryProvider));
});

/// Provider for permanently delete document use case
final permanentlyDeleteDocumentUseCaseProvider = Provider<PermanentlyDeleteDocument>((ref) {
  return PermanentlyDeleteDocument(ref.watch(documentRepositoryProvider));
});

/// Provider for get favorite documents use case
final getFavoriteDocumentsUseCaseProvider = Provider<GetFavoriteDocuments>((ref) {
  return GetFavoriteDocuments(ref.watch(documentRepositoryProvider));
});

/// Provider for PDF processor service
final pdfProcessorProvider = Provider<PdfProcessor>((ref) {
  return PdfProcessorImpl();
});

/// Provider for merge documents use case
final mergeDocumentsUseCaseProvider = Provider<MergeDocuments>((ref) {
  return MergeDocuments(
    ref.watch(documentRepositoryProvider),
    ref.watch(pdfProcessorProvider),
  );
});

/// Provider for convert images to PDF use case
final convertImagesToPdfUseCaseProvider = Provider<ConvertImagesToPdf>((ref) {
  return ConvertImagesToPdf(
    ref.watch(documentRepositoryProvider),
    ref.watch(pdfProcessorProvider),
  );
});

/// Provider for split PDF use case
final splitPdfUseCaseProvider = Provider<SplitPdf>((ref) {
  return SplitPdf(
    ref.watch(documentRepositoryProvider),
    ref.watch(pdfProcessorProvider),
  );
});

/// Provider for rename document use case
final renameDocumentUseCaseProvider = Provider<RenameDocument>((ref) {
  return RenameDocument(ref.watch(documentRepositoryProvider));
});

/// Provider for refresh metadata use case
final refreshMetadataUseCaseProvider = Provider<RefreshMetadata>((ref) {
  return RefreshMetadata(ref.watch(documentRepositoryProvider));
});
