/// Formatting utilities for the application
/// 
/// Provides formatting functions for dates, file sizes,
/// and other commonly formatted values.
library;

import 'package:intl/intl.dart';

/// Formatting utilities
abstract final class Formatters {
  /// Formats file size in human-readable format
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Formats date to relative time (e.g., "2 hours ago")
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Formats date to standard date string
  static String date(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Formats date with time
  static String dateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  /// Formats page count
  static String pageCount(int count) {
    return '$count ${count == 1 ? 'page' : 'pages'}';
  }

  /// Formats page number (e.g., "Page 1 of 10")
  static String pageNumber(int current, int total) {
    return 'Page $current of $total';
  }

  /// Truncates text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formats percentage
  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Formats zoom level
  static String zoomLevel(double scale) {
    return '${(scale * 100).toStringAsFixed(0)}%';
  }
}
