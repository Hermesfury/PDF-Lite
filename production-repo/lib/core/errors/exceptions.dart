// Custom exceptions for the application
// 
// These exceptions are thrown at the data layer and are typically
// converted to Failures at the domain/use case layer.

/// Exception thrown when a file operation fails
class FileException implements Exception {
  final String message;
  final String? path;
  
  const FileException({
    required this.message,
    this.path,
  });
  
  @override
  String toString() => 'FileException: $message${path != null ? ' ($path)' : ''}';
}

/// Exception thrown when a PDF operation fails
class PdfException implements Exception {
  final String message;
  final int? pageNumber;
  
  const PdfException({
    required this.message,
    this.pageNumber,
  });
  
  @override
  String toString() => 'PdfException: $message${pageNumber != null ? ' (page $pageNumber)' : ''}';
}

/// Exception thrown when storage operation fails
class StorageException implements Exception {
  final String message;
  final String? key;
  
  const StorageException({
    required this.message,
    this.key,
  });
  
  @override
  String toString() => 'StorageException: $message${key != null ? ' (key: $key)' : ''}';
}

/// Exception thrown when permission is denied
class PermissionException implements Exception {
  final String permission;
  final String message;
  
  const PermissionException({
    required this.permission,
    required this.message,
  });
  
  @override
  String toString() => 'PermissionException: $permission - $message';
}

/// Exception thrown for network-related errors
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  const NetworkException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Exception thrown when cache operation fails
class CacheException implements Exception {
  final String message;
  
  const CacheException({required this.message});
  
  @override
  String toString() => 'CacheException: $message';
}
