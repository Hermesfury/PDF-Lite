import 'package:equatable/equatable.dart';

/// Represents a PDF document in the application
/// 
/// This is the core business entity for documents in the system.
/// It contains all document metadata without any persistence details.
class Document extends Equatable {
  /// Unique identifier for the document
  final String id;
  
  /// Document file name
  final String name;
  
  /// Full file path
  final String path;
  
  /// File size in bytes
  final int sizeBytes;
  
  /// Number of pages in the PDF
  final int pageCount;
  
  /// Date when the document was added
  final DateTime dateAdded;
  
  /// Date when the document was last modified
  final DateTime dateModified;
  
  /// Date when the document was last opened
  final DateTime? lastOpened;
  
  /// Last page that was read
  final int? lastPageRead;
  
  /// Thumbnail image path (cached)
  final String? thumbnailPath;
  
  /// Whether the document is in trash
  final bool isInTrash;
  
  /// Whether the document is a favorite
  final bool isFavorite;
  
  /// Tags assigned to this document for categorization
  final List<String> tags;
  
  /// List of bookmarked page numbers
  final List<int> bookmarkedPages;

  const Document({
    required this.id,
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.pageCount,
    required this.dateAdded,
    required this.dateModified,
    this.lastOpened,
    this.lastPageRead,
    this.thumbnailPath,
    this.isInTrash = false,
    this.isFavorite = false,
    this.tags = const [],
    this.bookmarkedPages = const [],
  });

  /// Creates a copy of this document with the given fields replaced
  Document copyWith({
    String? id,
    String? name,
    String? path,
    int? sizeBytes,
    int? pageCount,
    DateTime? dateAdded,
    DateTime? dateModified,
    DateTime? lastOpened,
    int? lastPageRead,
    String? thumbnailPath,
    bool? isInTrash,
    bool? isFavorite,
    List<String>? tags,
    List<int>? bookmarkedPages,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      pageCount: pageCount ?? this.pageCount,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      lastOpened: lastOpened ?? this.lastOpened,
      lastPageRead: lastPageRead ?? this.lastPageRead,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isInTrash: isInTrash ?? this.isInTrash,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    sizeBytes,
    pageCount,
    dateAdded,
    dateModified,
    lastOpened,
    lastPageRead,
    thumbnailPath,
    isInTrash,
    isFavorite,
    tags,
    bookmarkedPages,
  ];
}
