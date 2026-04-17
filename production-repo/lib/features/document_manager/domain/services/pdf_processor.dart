
/// Interface for advanced PDF processing operations.
/// 
/// Follows the Strategy pattern to allow swapping between different 
/// PDF processing engines (e.g., pdf package, syncfusion, etc.).
abstract class PdfProcessor {
  /// Merges multiple PDF files into a single document.
  /// 
  /// [paths] - List of absolute paths to source PDF files.
  /// [outputName] - Suggested name for the resulting PDF.
  /// Returns the absolute path of the merged PDF file.
  Future<String> mergePdfs(List<String> paths, String outputName);

  /// Converts a sequence of images into a single PDF document.
  /// 
  /// [imagePaths] - List of absolute paths to source image files.
  /// [outputName] - Name for the resulting PDF.
  /// Returns the absolute path of the generated PDF file.
  Future<String> convertImagesToPdf(List<String> imagePaths, String outputName);

  /// Splits a PDF by extracting specific pages into a new document.
  Future<String> splitPdf(String inputPath, String outputPath, List<int> pagesToKeep);
}
