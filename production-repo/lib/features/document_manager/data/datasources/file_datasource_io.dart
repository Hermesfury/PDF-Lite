import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/exceptions.dart';
import 'file_datasource_interface.dart';

/// Implementation of file data source for native platforms
class FileDataSourceImpl implements FileDataSource {
  
  @override
  Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(directory.path, 'PDFs'));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

  /// Generates a unique file path that preserves the original filename.
  /// If a file with the same name exists, appends _1, _2, etc.
  Future<String> _uniqueDestinationPath(String docsDir, String originalName) async {
    final baseName = p.basenameWithoutExtension(originalName);
    final extension = p.extension(originalName);
    var destinationPath = p.join(docsDir, originalName);
    var counter = 1;

    while (await File(destinationPath).exists()) {
      final newName = '${baseName}_$counter$extension';
      destinationPath = p.join(docsDir, newName);
      counter++;
    }

    return destinationPath;
  }

  @override
  Future<String> copyFileToStorage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw FileException(
          message: 'Source file does not exist',
          path: sourcePath,
        );
      }
      
      final originalName = p.basename(sourcePath);
      final docsDir = await getDocumentsDirectory();
      final destinationPath = await _uniqueDestinationPath(docsDir, originalName);
      
      await sourceFile.copy(destinationPath);
      return destinationPath;
    } catch (e) {
      if (e is FileException) rethrow;
      throw FileException(
        message: 'Failed to copy file: $e',
        path: sourcePath,
      );
    }
  }

  @override
  Future<String> saveFileFromBytes(String fileName, Uint8List bytes) async {
    try {
      final docsDir = await getDocumentsDirectory();
      final destinationPath = await _uniqueDestinationPath(docsDir, fileName);
      
      final file = File(destinationPath);
      await file.writeAsBytes(bytes);
      
      return destinationPath;
    } catch (e) {
      throw FileException(
        message: 'Failed to save file from bytes: $e',
        path: fileName,
      );
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileException(
        message: 'Failed to delete file: $e',
        path: path,
      );
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  @override
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw FileException(
          message: 'File does not exist',
          path: path,
        );
      }
      return await file.length();
    } catch (e) {
      if (e is FileException) rethrow;
      throw FileException(
        message: 'Failed to get file size: $e',
        path: path,
      );
    }
  }

  @override
  Future<Uint8List> readFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw FileException(
          message: 'File does not exist',
          path: path,
        );
      }
      return await file.readAsBytes();
    } catch (e) {
      if (e is FileException) rethrow;
      throw FileException(
        message: 'Failed to read file: $e',
        path: path,
      );
    }
  }

  @override
  Future<String> renameFile(String oldPath, String newName) async {
    try {
      final oldFile = File(oldPath);
      if (!await oldFile.exists()) {
        throw FileException(message: 'File not found', path: oldPath);
      }

      final docsDir = await getDocumentsDirectory();
      // Ensure the NEW name is unique in the destination folder
      final newPath = await _uniqueDestinationPath(docsDir, newName);
      
      await oldFile.rename(newPath);
      return newPath;
    } catch (e) {
      throw FileException(message: 'Failed to rename file: $e', path: oldPath);
    }
  }
}
