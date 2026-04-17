import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pdf_document.dart';
import '../repositories/pdf_repository.dart';

/// Use case to load a PDF
class LoadPdf {
  final PdfRepository repository;

  LoadPdf(this.repository);

  Future<Either<Failure, Uint8List>> call(String path) {
    return repository.loadPdf(path);
  }
}

/// Use case to get page count
class GetPageCount {
  final PdfRepository repository;

  GetPageCount(this.repository);

  Future<Either<Failure, int>> call(String path) {
    return repository.getPageCount(path);
  }
}

/// Use case to get bookmarks
class GetBookmarks {
  final PdfRepository repository;

  GetBookmarks(this.repository);

  Future<Either<Failure, List<PdfBookmark>>> call(String path) {
    return repository.getBookmarks(path);
  }
}

/// Use case to search text in PDF
class SearchText {
  final PdfRepository repository;

  SearchText(this.repository);

  Future<Either<Failure, List<PdfSearchResult>>> call(
    String path,
    String query,
  ) {
    return repository.searchText(path, query);
  }
}

/// Use case to render a page
class RenderPage {
  final PdfRepository repository;

  RenderPage(this.repository);

  Future<Either<Failure, Uint8List>> call(
    String path,
    int pageNumber, {
    double scale = 1.0,
  }) {
    return repository.renderPage(path, pageNumber, scale: scale);
  }
}

/// Use case to check if PDF is encrypted
class CheckEncryption {
  final PdfRepository repository;

  CheckEncryption(this.repository);

  Future<Either<Failure, bool>> call(String path) {
    return repository.isEncrypted(path);
  }
}

/// Use case to get PDF metadata
class GetPdfMetadata {
  final PdfRepository repository;

  GetPdfMetadata(this.repository);

  Future<Either<Failure, Map<String, String>>> call(String path) {
    return repository.getMetadata(path);
  }
}
