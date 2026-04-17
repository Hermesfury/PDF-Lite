import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf;
import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_local_datasource.dart';
import '../datasources/file_datasource.dart';
import '../models/document_model.dart';

/// Implementation of DocumentRepository
class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource localDataSource;
  final FileDataSource fileDataSource;
  final Uuid _uuid = const Uuid();

  DocumentRepositoryImpl({
    required this.localDataSource,
    required this.fileDataSource,
  });

  @override
  Future<Either<Failure, List<Document>>> getDocuments({
    bool includeTrash = false,
    DocumentSortBy sortBy = DocumentSortBy.dateModified,
    SortOrder sortOrder = SortOrder.descending,
    String? searchQuery,
  }) async {
    try {
      final models = includeTrash 
          ? await localDataSource.getTrashDocuments()
          : await localDataSource.getAllDocuments();
      
      var documents = models.map((m) => m.toEntity()).toList();
      
      // Filter by search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        documents = documents.where((d) => 
          d.name.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }
      
      // Sort documents
      documents = _sortDocuments(documents, sortBy, sortOrder);
      
      return Right(documents);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get documents: $e'));
    }
  }

  List<Document> _sortDocuments(
    List<Document> documents,
    DocumentSortBy sortBy,
    SortOrder sortOrder,
  ) {
    final sorted = List<Document>.from(documents);
    
    sorted.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case DocumentSortBy.name:
          comparison = a.name.compareTo(b.name);
        case DocumentSortBy.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
        case DocumentSortBy.dateModified:
          comparison = a.dateModified.compareTo(b.dateModified);
        case DocumentSortBy.lastOpened:
          final aDate = a.lastOpened ?? DateTime(1970);
          final bDate = b.lastOpened ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
        case DocumentSortBy.size:
          comparison = a.sizeBytes.compareTo(b.sizeBytes);
      }
      
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    return sorted;
  }

  @override
  Future<Either<Failure, Document>> getDocument(String id) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }
      return Right(model.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get document: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> importDocument(String sourcePath) async {
    try {
      // Validate file
      if (!Validators.isValidPdfFile(sourcePath)) {
        return Left(PdfFailure.invalidFormat(sourcePath));
      }
      
      // Check file size
      final size = await fileDataSource.getFileSize(sourcePath);
      if (!Validators.isValidFileSize(size)) {
        return Left(FileFailure.tooLarge(sourcePath, size));
      }
      
      // Use the original filename as the document name
      final originalName = p.basename(sourcePath);
      
      // Check if a document with the same name already exists
      final existing = await localDataSource.findDocumentByName(originalName);
      if (existing != null) {
        // Update lastOpened and return existing document
        final updated = existing.copyWith(
          lastOpened: DateTime.now(),
          dateModified: DateTime.now(),
        );
        await localDataSource.updateDocument(updated);
        return Right(updated.toEntity());
      }
      
      // Copy to app storage (preserves original filename)
      final newPath = await fileDataSource.copyFileToStorage(sourcePath);
      
      // Get page count using syncfusion_flutter_pdf
      int pageCount = 0;
      try {
        final List<int> bytes = await File(newPath).readAsBytes();
        final pdfDoc = pdf.PdfDocument(inputBytes: bytes);
        pageCount = pdfDoc.pages.count;
        pdfDoc.dispose();
      } catch (e) {
        // Fallback or log error
      }
      
      // Create document model with original filename
      final now = DateTime.now();
      final model = DocumentModel(
        id: _uuid.v4(),
        name: originalName,
        path: newPath,
        sizeBytes: size,
        pageCount: pageCount,
        dateAdded: now,
        dateModified: now,
        lastOpened: null,
        lastPageRead: null,
        thumbnailPath: null,
        isInTrash: false,
        isFavorite: false,
      );
      
      // Save to local storage
      await localDataSource.saveDocument(model);
      
      return Right(model.toEntity());
    } on FileException catch (e) {
      return Left(FileFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to import document: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }
      
      // Move to trash
      final updated = model.copyWith(
        isInTrash: true,
        dateModified: DateTime.now(),
      );
      await localDataSource.updateDocument(updated);
      
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to delete document: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteDocument(String id) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }
      
      // Delete file
      await fileDataSource.deleteFile(model.path);
      
      // Delete from storage
      await localDataSource.deleteDocument(id);
      
      return const Right(null);
    } on FileException catch (e) {
      return Left(FileFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to delete document: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> restoreDocument(String id) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }
      
      final updated = model.copyWith(
        isInTrash: false,
        dateModified: DateTime.now(),
      );
      await localDataSource.updateDocument(updated);
      
      return Right(updated.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to restore document: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> updateDocument(Document document) async {
    try {
      final model = DocumentModel.fromEntity(document);
      await localDataSource.updateDocument(model);
      return Right(document);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to update document: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> toggleFavorite(String id) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }
      
      final updated = model.copyWith(
        isFavorite: !model.isFavorite,
        dateModified: DateTime.now(),
      );
      await localDataSource.updateDocument(updated);
      
      return Right(updated.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to toggle favorite: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> updateLastPage(String id, int pageNumber) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }
      
      final updated = model.copyWith(
        lastPageRead: pageNumber,
        lastOpened: DateTime.now(),
      );
      await localDataSource.updateDocument(updated);
      
      return Right(updated.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to update last page: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getFavoriteDocuments() async {
    try {
      final models = await localDataSource.getFavoriteDocuments();
      return Right(models.map((m) => m.toEntity()).toList());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get favorite documents: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Document>>> getTrashDocuments() async {
    try {
      final models = await localDataSource.getTrashDocuments();
      return Right(models.map((m) => m.toEntity()).toList());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get trash documents: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> emptyTrash() async {
    try {
      final trashDocs = await localDataSource.getTrashDocuments();
      
      for (final doc in trashDocs) {
        await fileDataSource.deleteFile(doc.path);
      }
      
      await localDataSource.clearTrash();
      
      return const Right(null);
    } on FileException catch (e) {
      return Left(FileFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to empty trash: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> renameDocument(String id, String newName) async {
    try {
      final model = await localDataSource.getDocument(id);
      if (model == null) {
        return Left(FileFailure.notFound(id));
      }

      // Rename physical file
      final newPath = await fileDataSource.renameFile(model.path, newName);
      
      // Update metadata in DB
      final updated = model.copyWith(
        name: p.basename(newPath),
        path: newPath,
        dateModified: DateTime.now(),
      );
      await localDataSource.updateDocument(updated);

      return Right(updated.toEntity());
    } on FileException catch (e) {
      return Left(FileFailure(message: e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to rename document: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> documentExists(String path) async {
    try {
      final exists = await fileDataSource.fileExists(path);
      return Right(exists);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to check document: $e'));
    }
  }
}
