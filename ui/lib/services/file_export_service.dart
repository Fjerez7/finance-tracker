import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service managing physical CSV/JSON export file generation and native device sharing.
class FileExportService {
  /// Writes CSV content to a temporary file and triggers the native OS Share Sheet.
  Future<void> shareCsv({
    required String csvContent,
    required String filename,
    String? subject,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = p.join(tempDir.path, filename);
    final file = File(filePath);
    await file.writeAsString(csvContent, encoding: utf8);

    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'text/csv', name: filename)],
      subject: subject ?? filename,
    );
  }

  /// Writes JSON snapshot content to a temporary file and triggers the native OS Share Sheet.
  Future<void> shareJson({
    required String jsonContent,
    required String filename,
    String? subject,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = p.join(tempDir.path, filename);
    final file = File(filePath);
    await file.writeAsString(jsonContent, encoding: utf8);

    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/json', name: filename)],
      subject: subject ?? filename,
    );
  }

  /// Prompts the user to pick a local .json backup file and returns its string content.
  Future<String?> pickLocalJsonBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.first;
    if (pickedFile.bytes != null) {
      return utf8.decode(pickedFile.bytes!);
    } else if (pickedFile.path != null) {
      final file = File(pickedFile.path!);
      return await file.readAsString(encoding: utf8);
    }
    return null;
  }
}
