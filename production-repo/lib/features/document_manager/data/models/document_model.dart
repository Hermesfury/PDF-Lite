import 'package:hive/hive.dart';
import '../../domain/entities/document.dart';

/// Hive model for document persistence
/// 
/// Uses Hive type adapter for persistence without code generation.
class DocumentModel extends HiveObject {
  String id;
  String name;
  String path;
  int sizeBytes;
  int pageCount;
  DateTime dateAdded;
  DateTime dateModified;
  DateTime? lastOpened;
  int? lastPageRead;
  String? thumbnailPath;
  bool isInTrash;
  bool isFavorite;
  List<String> tags;
  List<int> bookmarkedPages;

  DocumentModel({
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

  /// Creates a model from a domain entity
  factory DocumentModel.fromEntity(Document entity) {
    return DocumentModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      sizeBytes: entity.sizeBytes,
      pageCount: entity.pageCount,
      dateAdded: entity.dateAdded,
      dateModified: entity.dateModified,
      lastOpened: entity.lastOpened,
      lastPageRead: entity.lastPageRead,
      thumbnailPath: entity.thumbnailPath,
      isInTrash: entity.isInTrash,
      isFavorite: entity.isFavorite,
      tags: entity.tags,
      bookmarkedPages: entity.bookmarkedPages,
    );
  }

  /// Converts to a domain entity
  Document toEntity() {
    return Document(
      id: id,
      name: name,
      path: path,
      sizeBytes: sizeBytes,
      pageCount: pageCount,
      dateAdded: dateAdded,
      dateModified: dateModified,
      lastOpened: lastOpened,
      lastPageRead: lastPageRead,
      thumbnailPath: thumbnailPath,
      isInTrash: isInTrash,
      isFavorite: isFavorite,
      tags: tags,
      bookmarkedPages: bookmarkedPages,
    );
  }

  /// Creates a copy with the given fields replaced
  DocumentModel copyWith({
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
    return DocumentModel(
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
}

/// Hive type adapter for DocumentModel
class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 0;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      name: fields[1] as String,
      path: fields[2] as String,
      sizeBytes: fields[3] as int,
      pageCount: fields[4] as int,
      dateAdded: fields[5] as DateTime,
      dateModified: fields[6] as DateTime,
      lastOpened: fields[7] as DateTime?,
      lastPageRead: fields[8] as int?,
      thumbnailPath: fields[9] as String?,
      isInTrash: fields[10] as bool,
      isFavorite: fields[11] as bool,
      tags: (fields[12] as List?)?.cast<String>() ?? [],
      bookmarkedPages: (fields[13] as List?)?.cast<int>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.sizeBytes)
      ..writeByte(4)
      ..write(obj.pageCount)
      ..writeByte(5)
      ..write(obj.dateAdded)
      ..writeByte(6)
      ..write(obj.dateModified)
      ..writeByte(7)
      ..write(obj.lastOpened)
      ..writeByte(8)
      ..write(obj.lastPageRead)
      ..writeByte(9)
      ..write(obj.thumbnailPath)
      ..writeByte(10)
      ..write(obj.isInTrash)
      ..writeByte(11)
      ..write(obj.isFavorite)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.bookmarkedPages);
  }
}
