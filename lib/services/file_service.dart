import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class FileService {
  Future<String?> importText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'csv']);

    if (result != null && result.files.isNotEmpty) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        try {
          return await File(filePath).readAsString();
        } catch (e) {
          throw Exception('Failed to read file.');
        }
      }
    }
    return null;
  }

  Future<String> exportText(String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/encrypted_text_$timestamp.txt');

    await file.writeAsString(text);
    return file.path;
  }
}
