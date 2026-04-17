import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pdf_document.dart';

/// Repository interface for PDF viewing operations
/// 
/// This defines the contract for PDF rendering and manipulation.
abstract class PdfRepository {
  /// Load a PDF from the given file path
  Future<Either<Failure, Uint8List>> loadPdf(String path);

  /// Get the number of pages in a PDF
  Future<Either<Failure, int>> getPageCount(String path);

  /// Get the table of contents/bookmarks
  Future<Either<Failure, List<PdfBookmark>>> getBookmarks(String path);

  /// Search for text in the PDF
  Future<Either<Failure, List<PdfSearchResult>>> searchText(
    String path,
    String query,
  );

  /// Render a specific page as an image
  Future<Either<Failure, Uint8List>> renderPage(
    String path,
    int pageNumber, {
    double scale = 1.0,
  });

  /// Check if a PDF is encrypted
  Future<Either<Failure, bool>> isEncrypted(String path);

  /// Get PDF metadata
  Future<Either<Failure, Map<String, String>>> getMetadata(String path);
}
