import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'pdf_service.dart';

class PdfServiceImpl implements PdfService {
  const PdfServiceImpl();

  @override
  Future<File> saveToFile({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final dir  = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  @override
  Future<void> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
  }) async {
    final file = await saveToFile(pdfBytes: pdfBytes, fileName: fileName);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: subject ?? fileName,
    );
  }

  @override
  Future<void> openFile(File file) async {
    await OpenFile.open(file.path);
  }

  @override
  Future<void> printPdf({
    required Uint8List pdfBytes,
    required String documentName,
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: documentName,
    );
  }
}