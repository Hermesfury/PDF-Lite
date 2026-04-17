/// Validation utilities for the application
/// 
/// Provides validation functions for common input types
/// like file paths, emails, and other data.
library;

import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

/// Validates file paths and file extensions
abstract final class Validators {
  /// Validates if a file path has a supported PDF extension
  static bool isValidPdfFile(String path) {
    final extension = p.extension(path).toLowerCase().replaceFirst('.', '');
    return SupportedFormats.pdf.contains(extension);
  }

  /// Validates if a file path has any supported document extension
  static bool isValidDocumentFile(String path) {
    final extension = p.extension(path).toLowerCase().replaceFirst('.', '');
    return SupportedFormats.all.contains(extension);
  }

  /// Validates if file size is within acceptable limits
  static bool isValidFileSize(int sizeBytes) {
    return sizeBytes >= FileLimits.minFileSizeBytes && 
           sizeBytes <= FileLimits.maxFileSizeBytes;
  }

  /// Validates file name - not empty, no invalid characters
  static bool isValidFileName(String name) {
    if (name.isEmpty) return false;
    
    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(name)) return false;
    
    // Check for reserved names on Windows
    final reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
    ];
    final baseName = name.split('.').first.toUpperCase();
    if (reservedNames.contains(baseName)) return false;
    
    return true;
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates if a string is not empty after trimming
  static bool isNotEmpty(String? value) {
    return value?.trim().isNotEmpty ?? false;
  }

  /// Validates minimum length
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// Validates maximum length
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }
}
