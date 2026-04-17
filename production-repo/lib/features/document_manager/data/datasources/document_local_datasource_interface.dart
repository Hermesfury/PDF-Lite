import '../models/document_model.dart';

/// Local data source for document operations
abstract class DocumentLocalDataSource {
  /// Initialize the data source
  Future<void> init();
  
  /// Get all documents
  Future<List<DocumentModel>> getAllDocuments();
  
  /// Get document by ID
  Future<DocumentModel?> getDocument(String id);
  
  /// Save a document
  Future<void> saveDocument(DocumentModel document);
  
  /// Delete a document
  Future<void> deleteDocument(String id);
  
  /// Update a document
  Future<void> updateDocument(DocumentModel document);
  
  /// Get documents in trash
  Future<List<DocumentModel>> getTrashDocuments();
  
  /// Get favorite documents
  Future<List<DocumentModel>> getFavoriteDocuments();
  
  /// Find a non-trashed document by name
  Future<DocumentModel?> findDocumentByName(String name);

  /// Clear all documents in trash
  Future<void> clearTrash();
}
