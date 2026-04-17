/// Extension methods for String
/// 
/// Provides convenient string manipulation methods.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Checks if the string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if the string contains only digits
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Truncates the string to the specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Removes all whitespace from the string
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if the string is null or empty
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Checks if the string is not null or empty
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }

  /// Returns the file extension without the dot
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1 || lastDot == length - 1) return '';
    return substring(lastDot + 1).toLowerCase();
  }

  /// Returns the file name without extension
  String get fileNameWithoutExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return this;
    return substring(0, lastDot);
  }
}
