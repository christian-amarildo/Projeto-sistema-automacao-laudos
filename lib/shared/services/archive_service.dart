import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ArchiveService {
  /// Extracts a zip/fcase file to a temporary directory and returns the path to that directory.
  Future<String> extractPackage(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final tempDir = await getTemporaryDirectory();
    final extractionDir = Directory(path.join(tempDir.path,
        'forensichain_extraction_${DateTime.now().millisecondsSinceEpoch}'));

    if (!await extractionDir.exists()) {
      await extractionDir.create(recursive: true);
    }

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content;
        final outFile = File(path.join(extractionDir.path, filename));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(path.join(extractionDir.path, filename))
            .create(recursive: true);
      }
    }

    return extractionDir.path;
  }

  /// Reads the manifest.json file from the extracted directory.
  Future<Map<String, dynamic>> readManifest(String extractedPath) async {
    final manifestFile = File(path.join(extractedPath, 'manifest.json'));

    if (!await manifestFile.exists()) {
      throw Exception('Arquivo manifest.json não encontrado no pacote.');
    }

    final content = await manifestFile.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }
}
