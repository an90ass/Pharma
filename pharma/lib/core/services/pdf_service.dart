import 'dart:io';
import 'dart:typed_data';


abstract class PdfService {

  Future<File> saveToFile({
    required Uint8List pdfBytes,
    required String fileName,
  });

  Future<void> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
  });


  Future<void> openFile(File file);


  Future<void> printPdf({
    required Uint8List pdfBytes,
    required String documentName,
  });
}