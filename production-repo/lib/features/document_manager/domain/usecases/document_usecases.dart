import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document.dart';
import '../repositories/document_repository.dart';
import '../services/pdf_processor.dart';

/// Use case to get all documents
class GetDocuments {
  final DocumentRepository repository;

  GetDocuments(this.repository);

  Future<Either<Failure, List<Document>>> call({
    bool includeTrash = false,
    DocumentSortBy sortBy = DocumentSortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    String? searchQuery,
  }) {
    return repository.getDocuments(
      includeTrash: includeTrash,
      sortBy: sortBy,
      sortOrder: sortOrder,
      searchQuery: searchQuery,
    );
  }
}

/// Use case to import a document
class ImportDocument {
  final DocumentRepository repository;

  ImportDocument(this.repository);

  Future<Either<Failure, Document>> call(String sourcePath) {
    return repository.importDocument(sourcePath);
  }
}

/// Use case to delete a document (move to trash)
class DeleteDocument {
  final DocumentRepository repository;

  DeleteDocument(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteDocument(id);
  }
}

/// Use case for merging multiple PDFs
class MergeDocuments {
  final DocumentRepository repository;
  final PdfProcessor processor;

  MergeDocuments(this.repository, this.processor);

  Future<Either<Failure, Document>> call(List<String> paths, String outputName) async {
    try {
      final outputPath = await processor.mergePdfs(paths, outputName);
      return repository.importDocument(outputPath);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to merge documents: $e'));
    }
  }
}

/// Use case for converting images to PDF
class ConvertImagesToPdf {
  final DocumentRepository repository;
  final PdfProcessor processor;

  ConvertImagesToPdf(this.repository, this.processor);

  Future<Either<Failure, Document>> call(List<String> imagePaths, String outputName) async {
    try {
      final outputPath = await processor.convertImagesToPdf(imagePaths, outputName);
      return repository.importDocument(outputPath);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to convert images: $e'));
    }
  }
}

/// Use case for splitting a PDF
class SplitPdf {
  final DocumentRepository repository;
  final PdfProcessor processor;

  SplitPdf(this.repository, this.processor);

  Future<Either<Failure, Document>> call(String inputPath, String outputName, List<int> pagesToKeep) async {
    try {
      final outputPath = await processor.splitPdf(inputPath, outputName, pagesToKeep);
      return repository.importDocument(outputPath);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to split PDF: $e'));
    }
  }
}

/// Use case to permanently delete a document
class PermanentlyDeleteDocument {
  final DocumentRepository repository;

  PermanentlyDeleteDocument(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.permanentlyDeleteDocument(id);
  }
}

/// Use case to restore a document from trash
class RestoreDocument {
  final DocumentRepository repository;

  RestoreDocument(this.repository);

  Future<Either<Failure, Document>> call(String id) {
    return repository.restoreDocument(id);
  }
}

/// Use case to toggle favorite status
class ToggleFavorite {
  final DocumentRepository repository;

  ToggleFavorite(this.repository);

  Future<Either<Failure, Document>> call(String id) {
    return repository.toggleFavorite(id);
  }
}

/// Use case to update last read page
class UpdateLastPage {
  final DocumentRepository repository;

  UpdateLastPage(this.repository);

  Future<Either<Failure, Document>> call(String id, int pageNumber) {
    return repository.updateLastPage(id, pageNumber);
  }
}

/// Use case to get favorite documents
class GetFavoriteDocuments {
  final DocumentRepository repository;

  GetFavoriteDocuments(this.repository);

  Future<Either<Failure, List<Document>>> call() {
    return repository.getFavoriteDocuments();
  }
}

/// Use case to get trashed documents
class GetTrashDocuments {
  final DocumentRepository repository;

  GetTrashDocuments(this.repository);

  Future<Either<Failure, List<Document>>> call() {
    return repository.getTrashDocuments();
  }
}

/// Use case to empty the trash
class EmptyTrash {
  final DocumentRepository repository;

  EmptyTrash(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.emptyTrash();
  }
}

/// Use case to get a single document
class GetDocument {
  final DocumentRepository repository;

  GetDocument(this.repository);

  Future<Either<Failure, Document>> call(String id) {
    return repository.getDocument(id);
  }
}

/// Use case to rename a document
class RenameDocument {
  final DocumentRepository repository;

  RenameDocument(this.repository);

  Future<Either<Failure, Document>> call(String id, String newName) {
    return repository.renameDocument(id, newName);
  }
}

/// Use case to refresh document metadata (size, pages)
class RefreshMetadata {
  final DocumentRepository repository;

  RefreshMetadata(this.repository);

  Future<Either<Failure, Document>> call(Document document) async {
    return repository.updateDocument(document);
  }
}
