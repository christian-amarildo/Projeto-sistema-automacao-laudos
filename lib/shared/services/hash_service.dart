import 'dart:io';
import 'package:crypto/crypto.dart';

class HashService {
  Future<String> calculateFileHash(File file) async {
    if (!await file.exists()) {
      throw FileSystemException("File not found", file.path);
    }
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }
}
