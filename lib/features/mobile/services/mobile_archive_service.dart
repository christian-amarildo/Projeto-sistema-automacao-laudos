import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../collection_page.dart'; // For PhotoSlot

class MobileArchiveService {
  Future<String> createCasePackage({
    required String caseId,
    required String bop,
    required String type,
    required List<PhotoSlot> slots,
  }) async {
    // 1. Create a temporary directory for staging
    final tempDir = await getTemporaryDirectory();
    final stagingDir = Directory(path.join(tempDir.path, 'staging_$caseId'));
    if (await stagingDir.exists()) {
      await stagingDir.delete(recursive: true);
    }
    await stagingDir.create();

    final imagesDir = Directory(path.join(stagingDir.path, 'images'));
    await imagesDir.create();

    // 2. Prepare Manifest Data
    final List<Map<String, dynamic>> evidenceList = [];

    // 3. Copy Images and Build Manifest
    for (var slot in slots) {
      if (slot.imageUrl != null) {
        final sourceFile = File(slot.imageUrl!);
        if (await sourceFile.exists()) {
          final fileName = 'evidence_${slot.id}.jpg';
          final destPath = path.join(imagesDir.path, fileName);
          await sourceFile.copy(destPath);

          evidenceList.add({
            'id': slot.id,
            'name': slot.name,
            'filename': 'images/$fileName',
            'hash': slot.hash,
            'observation': slot.observation,
            'required': slot.required,
            'is_custom': slot.isCustom,
            'captured_at': slot.capturedAt?.toIso8601String() ??
                DateTime.now().toIso8601String(),
          });
        }
      }
    }

    final manifest = {
      'case_id': caseId,
      'bop': bop,
      'device_type': type,
      'created_at': DateTime.now().toIso8601String(),
      'evidence': evidenceList,
      'version': '1.0.0',
    };

    // 4. Write Manifest
    final manifestFile = File(path.join(stagingDir.path, 'manifest.json'));
    await manifestFile.writeAsString(jsonEncode(manifest));

    // 5. Create ZIP
    final appDocDir = await getApplicationDocumentsDirectory();
    final zipFilePath = path.join(appDocDir.path, 'case_$caseId.zip');

    final encoder = ZipFileEncoder();
    encoder.create(zipFilePath);
    encoder.addDirectory(stagingDir);
    encoder.close();

    // 6. Cleanup
    await stagingDir.delete(recursive: true);

    return zipFilePath;
  }
}
