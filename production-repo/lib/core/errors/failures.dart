import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// 
/// Uses the Either pattern with Dartz for functional error handling.
/// All failures are immutable and comparable.
abstract class Failure extends Equatable {
  /// The error message to display to the user
  final String message;
  
  /// Optional error code for logging/tracking
  final String? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// Failure related to file operations (reading, writing, deleting)
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
  });
  
  factory FileFailure.notFound(String path) => FileFailure(
    message: 'File not found: $path',
    code: 'FILE_NOT_FOUND',
  );
  
  factory FileFailure.accessDenied(String path) => FileFailure(
    message: 'Access denied to file: $path',
    code: 'FILE_ACCESS_DENIED',
  );
  
  factory FileFailure.tooLarge(String path, int size) => FileFailure(
    message: 'File too large: $path ($size bytes)',
    code: 'FILE_TOO_LARGE',
  );
  
  factory FileFailure.corrupted(String path) => FileFailure(
    message: 'File is corrupted: $path',
    code: 'FILE_CORRUPTED',
  );
  
  factory FileFailure.writeError(String path, String reason) => FileFailure(
    message: 'Failed to write file: $path. Reason: $reason',
    code: 'FILE_WRITE_ERROR',
  );
}

/// Failure related to PDF operations
class PdfFailure extends Failure {
  const PdfFailure({
    required super.message,
    super.code,
  });
  
  factory PdfFailure.invalidFormat(String path) => PdfFailure(
    message: 'Invalid PDF format: $path',
    code: 'PDF_INVALID_FORMAT',
  );
  
  factory PdfFailure.renderError(int pageNumber, String reason) => PdfFailure(
    message: 'Failed to render page $pageNumber: $reason',
    code: 'PDF_RENDER_ERROR',
  );
  
  factory PdfFailure.encryptionNotSupported() => const PdfFailure(
    message: 'Encrypted PDFs are not supported',
    code: 'PDF_ENCRYPTED',
  );
  
  factory PdfFailure.annotationError(String reason) => PdfFailure(
    message: 'Failed to apply annotation: $reason',
    code: 'PDF_ANNOTATION_ERROR',
  );
  
  factory PdfFailure.saveError(String reason) => PdfFailure(
    message: 'Failed to save PDF: $reason',
    code: 'PDF_SAVE_ERROR',
  );
}

/// Failure related to storage operations
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
  
  factory StorageFailure.readError(String key) => StorageFailure(
    message: 'Failed to read from storage: $key',
    code: 'STORAGE_READ_ERROR',
  );
  
  factory StorageFailure.writeError(String key) => StorageFailure(
    message: 'Failed to write to storage: $key',
    code: 'STORAGE_WRITE_ERROR',
  );
  
  factory StorageFailure.deleteError(String key) => StorageFailure(
    message: 'Failed to delete from storage: $key',
    code: 'STORAGE_DELETE_ERROR',
  );
  
  factory StorageFailure.boxNotFound(String boxName) => StorageFailure(
    message: 'Storage box not found: $boxName',
    code: 'STORAGE_BOX_NOT_FOUND',
  );
}

/// Failure related to permission issues
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
  
  factory PermissionFailure.storage() => const PermissionFailure(
    message: 'Storage permission is required to access files',
    code: 'PERMISSION_STORAGE',
  );
  
  factory PermissionFailure.camera() => const PermissionFailure(
    message: 'Camera permission is required for scanning',
    code: 'PERMISSION_CAMERA',
  );
  
  factory PermissionFailure.denied(String permission) => PermissionFailure(
    message: 'Permission denied: $permission',
    code: 'PERMISSION_DENIED',
  );
}

/// Failure related to network operations
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
  
  factory NetworkFailure.noConnection() => const NetworkFailure(
    message: 'No internet connection',
    code: 'NETWORK_NO_CONNECTION',
  );
  
  factory NetworkFailure.timeout() => const NetworkFailure(
    message: 'Connection timed out',
    code: 'NETWORK_TIMEOUT',
  );
  
  factory NetworkFailure.serverError(int statusCode) => NetworkFailure(
    message: 'Server error: $statusCode',
    code: 'NETWORK_SERVER_ERROR',
  );
  
  factory NetworkFailure.unknown(String reason) => NetworkFailure(
    message: 'Network error: $reason',
    code: 'NETWORK_UNKNOWN',
  );
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
  });
  
  factory UnexpectedFailure.fromException(Exception e) => UnexpectedFailure(
    message: 'An unexpected error occurred: ${e.toString()}',
    code: 'UNEXPECTED_ERROR',
  );
}
