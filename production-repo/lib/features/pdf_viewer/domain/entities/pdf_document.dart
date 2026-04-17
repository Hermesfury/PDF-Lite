import 'package:equatable/equatable.dart';

/// Represents a PDF bookmark/outline item
class PdfBookmark extends Equatable {
  /// Bookmark title
  final String title;
  
  /// Page number (0-based index)
  final int pageNumber;
  
  /// Optional child bookmarks
  final List<PdfBookmark>? children;

  const PdfBookmark({
    required this.title,
    required this.pageNumber,
    this.children,
  });

  @override
  List<Object?> get props => [title, pageNumber, children];
}

/// Represents a text search result in a PDF
class PdfSearchResult extends Equatable {
  /// The matched text
  final String text;
  
  /// Page number where the match was found (0-based index)
  final int pageNumber;
  
  /// Start position of the match in the page
  final int startIndex;
  
  /// End position of the match in the page
  final int endIndex;

  const PdfSearchResult({
    required this.text,
    required this.pageNumber,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  List<Object?> get props => [text, pageNumber, startIndex, endIndex];
}

/// Represents the current view state of a PDF
class PdfViewState extends Equatable {
  /// Current page number (0-based index)
  final int currentPage;
  
  /// Total number of pages
  final int totalPages;
  
  /// Current zoom scale
  final double scale;
  
  /// Whether the document is currently loading
  final bool isLoading;
  
  /// Error message if any
  final String? error;

  const PdfViewState({
    this.currentPage = 0,
    this.totalPages = 0,
    this.scale = 1.0,
    this.isLoading = false,
    this.error,
  });

  /// Creates a copy with the given fields replaced
  PdfViewState copyWith({
    int? currentPage,
    int? totalPages,
    double? scale,
    bool? isLoading,
    String? error,
  }) {
    return PdfViewState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      scale: scale ?? this.scale,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [currentPage, totalPages, scale, isLoading, error];
}
