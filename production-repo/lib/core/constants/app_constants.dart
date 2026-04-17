/// Application-wide constants for FluxPDF
/// 
/// This file contains all constant values used throughout the app,
/// organized by category for maintainability.
library;

import 'package:flutter/material.dart';

/// Application metadata constants
abstract final class AppConstants {
  /// Application name
  static const String appName = 'FluxPDF';
  
  /// Application version
  static const String appVersion = '1.0.0';
  
  /// Build number
  static const int buildNumber = 1;
}

/// API-related constants (for future cloud sync)
abstract final class ApiConstants {
  static const String baseUrl = 'https://api.fluxpdf.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Storage keys for local persistence
abstract final class StorageKeys {
  static const String documentsBox = 'documents_box';
  static const String settingsBox = 'settings_box';
  static const String bookmarksBox = 'bookmarks_box';
  static const String annotationsBox = 'annotations_box';
  static const String readPositionsBox = 'read_positions_box';
  
  /// Theme preference key
  static const String themeMode = 'theme_mode';
  
  /// Last opened document ID
  static const String lastOpenedDocumentId = 'last_opened_document_id';
}

/// Pagination and caching constants
abstract final class PaginationConstants {
  /// Number of documents to load per page
  static const int documentsPerPage = 20;
  
  /// Number of PDF pages to pre-render ahead
  static const int preRenderPages = 3;
  
  /// Maximum cached PDF pages in memory
  static const int maxCachedPages = 10;
  
  /// Thumbnail size for document list
  static const Size thumbnailSize = Size(120, 160);
}

/// File size limits
abstract final class FileLimits {
  /// Maximum PDF file size (50 MB)
  static const int maxFileSizeBytes = 50 * 1024 * 1024;
  
  /// Minimum PDF file size (1 KB)
  static const int minFileSizeBytes = 1024;
}

/// Animation durations
abstract final class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  /// Page transition duration
  static const Duration pageTransition = Duration(milliseconds: 350);
}

/// UI dimension constants
abstract final class AppDimensions {
  /// Standard padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  /// Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  /// Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  
  /// Document grid
  static const double documentGridItemWidth = 160.0;
  static const double documentGridItemHeight = 220.0;
}

/// Supported file extensions
abstract final class SupportedFormats {
  static const List<String> pdf = ['pdf'];
  static const List<String> images = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> all = [...pdf, ...images];
}
