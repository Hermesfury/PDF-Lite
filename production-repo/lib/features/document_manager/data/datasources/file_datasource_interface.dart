import 'dart:typed_data';

/// Data source for file system operations
abstract class FileDataSource {
  /// Copy a file to app storage
  Future<String> copyFileToStorage(String sourcePath);
  
  /// Delete a file
  Future<void> deleteFile(String path);
  
  /// Check if file exists
  Future<bool> fileExists(String path);
  
  /// Get file size
  Future<int> getFileSize(String path);
  
  /// Read file as bytes
  Future<Uint8List> readFile(String path);
  
  /// Save a file from bytes
  Future<String> saveFileFromBytes(String fileName, Uint8List bytes);
  
  /// Get the documents directory
  Future<String> getDocumentsDirectory();

  /// Rename a file in storage
  Future<String> renameFile(String oldPath, String newName);
}
