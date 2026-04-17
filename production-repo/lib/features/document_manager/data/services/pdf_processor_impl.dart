import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/services/pdf_processor.dart';

/// Implementation of [PdfProcessor] using [syncfusion_flutter_pdf].
/// 
/// This implementation provides industrial-grade PDF manipulation 
/// supporting merging and image conversion with high performance.
class PdfProcessorImpl implements PdfProcessor {
  @override
  Future<String> mergePdfs(List<String> paths, String outputName) async {
    try {
      // Create a output document
      final PdfDocument document = PdfDocument();
      
      for (final String path in paths) {
        final File file = File(path);
        if (!await file.exists()) {
          throw FileException(message: 'Source file not found: $path');
        }
        
        final List<int> bytes = await file.readAsBytes();
        final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);
        
        // Merge page by page
        for (int i = 0; i < sourceDoc.pages.count; i++) {
          document.pages.add().graphics.drawPdfTemplate(
            sourceDoc.pages[i].createTemplate(),
            const Offset(0, 0),
          );
        }
        sourceDoc.dispose();
      }

      final String outputPath = await _getOutputPath(outputName);
      final List<int> outputBytes = await document.save();
      await File(outputPath).writeAsBytes(outputBytes);
      
      document.dispose();
      return outputPath;
    } catch (e) {
      throw FileException(message: 'Failed to merge PDFs: $e');
    }
  }

  @override
  Future<String> convertImagesToPdf(List<String> imagePaths, String outputName) async {
    try {
      final PdfDocument document = PdfDocument();
      int validImages = 0;

      for (final String imagePath in imagePaths) {
        final File imageFile = File(imagePath);
        if (!await imageFile.exists()) continue;

        try {
          final List<int> imageBytes = await imageFile.readAsBytes();
          final PdfBitmap image = PdfBitmap(imageBytes);

          // Add page with image dimensions
          final PdfPage page = document.pages.add();
          page.graphics.drawImage(
            image,
            Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height),
          );
          validImages++;
        } catch (e) {
          // Skip invalid images
          continue;
        }
      }

      if (validImages == 0) {
        document.dispose();
        throw FileException(message: 'No valid images found to convert');
      }

      final String outputPath = await _getOutputPath(outputName);
      final List<int> outputBytes = await document.save();
      await File(outputPath).writeAsBytes(outputBytes);

      document.dispose();
      return outputPath;
    } catch (e) {
      throw FileException(message: 'Failed to convert images to PDF: $e');
    }
  }

  @override
  Future<String> splitPdf(String inputPath, String outputPath, List<int> pagesToKeep) async {
    try {
      final File file = File(inputPath);
      if (!await file.exists()) {
        throw FileException(message: 'Source file not found: $inputPath');
      }

      final List<int> bytes = await file.readAsBytes();
      final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);
      final PdfDocument outputDoc = PdfDocument();

      for (final int pageIndex in pagesToKeep) {
        if (pageIndex >= 0 && pageIndex < sourceDoc.pages.count) {
          final PdfPage sourcePage = sourceDoc.pages[pageIndex];
          outputDoc.pages.add().graphics.drawPdfTemplate(
            sourcePage.createTemplate(),
            const Offset(0, 0),
          );
        }
      }

      final List<int> outputBytes = await outputDoc.save();
      await File(outputPath).writeAsBytes(outputBytes);
      
      sourceDoc.dispose();
      outputDoc.dispose();
      
      return outputPath;
    } catch (e) {
      throw FileException(message: 'Failed to split PDF: $e');
    }
  }





  Future<String> _getOutputPath(String baseName) async {
    final directory = await getApplicationDocumentsDirectory();
    final String cleanName = baseName.replaceAll(RegExp(r'[^\w\s\.]'), '_');
    final String fileName = cleanName.endsWith('.pdf') ? cleanName : '$cleanName.pdf';
    
    String finalPath = p.join(directory.path, fileName);
    int counter = 1;

    while (await File(finalPath).exists()) {
      final nameWithoutExt = p.basenameWithoutExtension(fileName);
      finalPath = p.join(directory.path, '${nameWithoutExt}_$counter.pdf');
      counter++;
    }

    return finalPath;
  }
}
