import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document.dart';

/// Sorting options for document list
enum DocumentSortBy {
  name,
  dateAdded,
  dateModified,
  lastOpened,
  size,
}

/// Sort order
enum SortOrder {
  ascending,
  descending,
}

/// Repository interface for document operations
/// 
/// This defines the contract for document data operations.
/// Implementations must handle local storage and file system operations.
abstract class DocumentRepository {
  /// Get all documents (optionally filtered and sorted)
  Future<Either<Failure, List<Document>>> getDocuments({
    bool includeTrash = false,
    DocumentSortBy sortBy = DocumentSortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    String? searchQuery,
  });

  /// Get a single document by ID
  Future<Either<Failure, Document>> getDocument(String id);

  /// Import a document from external source
  /// Returns the created document
  Future<Either<Failure, Document>> importDocument(String sourcePath);

  /// Delete a document (move to trash)
  Future<Either<Failure, void>> deleteDocument(String id);

  /// Permanently delete a document
  Future<Either<Failure, void>> permanentlyDeleteDocument(String id);

  /// Restore a document from trash
  Future<Either<Failure, Document>> restoreDocument(String id);

  /// Update document metadata
  Future<Either<Failure, Document>> updateDocument(Document document);

  /// Toggle favorite status
  Future<Either<Failure, Document>> toggleFavorite(String id);

  /// Update last read page
  Future<Either<Failure, Document>> updateLastPage(String id, int pageNumber);

  /// Get all favorite documents
  Future<Either<Failure, List<Document>>> getFavoriteDocuments();

  /// Get all trashed documents
  Future<Either<Failure, List<Document>>> getTrashDocuments();

  /// Empty the trash
  Future<Either<Failure, void>> emptyTrash();

  /// Check if a document exists
  Future<Either<Failure, bool>> documentExists(String path);

  /// Rename a document
  Future<Either<Failure, Document>> renameDocument(String id, String newName);
}
