import 'package:hive/hive.dart';
import '../models/document_model.dart';
import '../../../../core/errors/exceptions.dart';
import 'document_local_datasource_interface.dart';

/// Implementation of local data source using Hive for native platforms
class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  static const String _boxName = 'documents_box';
  
  static final DocumentLocalDataSourceImpl _instance = DocumentLocalDataSourceImpl._internal();
  factory DocumentLocalDataSourceImpl() => _instance;
  DocumentLocalDataSourceImpl._internal();
  
  Box<DocumentModel>? _box;

  @override
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DocumentModelAdapter());
    }
    _box = await Hive.openBox<DocumentModel>(_boxName);
  }

  Box<DocumentModel> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw const StorageException(
        message: 'Documents box is not initialized',
        key: _boxName,
      );
    }
    return _box!;
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    try {
      return _safeBox.values.where((doc) => !doc.isInTrash).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get documents: $e');
    }
  }

  @override
  Future<DocumentModel?> getDocument(String id) async {
    try {
      return _safeBox.get(id);
    } catch (e) {
      throw StorageException(message: 'Failed to get document: $e');
    }
  }

  @override
  Future<void> saveDocument(DocumentModel document) async {
    try {
      await _safeBox.put(document.id, document);
    } catch (e) {
      throw StorageException(message: 'Failed to save document: $e');
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      await _safeBox.delete(id);
    } catch (e) {
      throw StorageException(message: 'Failed to delete document: $e');
    }
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    try {
      await _safeBox.put(document.id, document);
    } catch (e) {
      throw StorageException(message: 'Failed to update document: $e');
    }
  }

  @override
  Future<List<DocumentModel>> getTrashDocuments() async {
    try {
      return _safeBox.values.where((doc) => doc.isInTrash).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get trash documents: $e');
    }
  }

  @override
  Future<List<DocumentModel>> getFavoriteDocuments() async {
    try {
      return _safeBox.values.where((doc) => doc.isFavorite && !doc.isInTrash).toList();
    } catch (e) {
      throw StorageException(message: 'Failed to get favorite documents: $e');
    }
  }

  @override
  Future<DocumentModel?> findDocumentByName(String name) async {
    try {
      final docs = _safeBox.values.where(
        (doc) => doc.name == name && !doc.isInTrash,
      );
      return docs.isEmpty ? null : docs.first;
    } catch (e) {
      throw StorageException(message: 'Failed to find document by name: $e');
    }
  }

  @override
  Future<void> clearTrash() async {
    try {
      final trashDocs = _safeBox.values.where((doc) => doc.isInTrash).toList();
      for (final doc in trashDocs) {
        await _safeBox.delete(doc.id);
      }
    } catch (e) {
      throw StorageException(message: 'Failed to clear trash: $e');
    }
  }
}
