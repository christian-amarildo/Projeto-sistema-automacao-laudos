import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PythonBridgeService {
  Future<bool> executeAutomation({
    required String pythonPath,
    required String scriptPath,
    required String evidenceJsonPath,
    required String outputDir,
  }) async {
    try {
      String executable;
      List<String> arguments;

      if (kReleaseMode) {
        // Production Mode: Use bundled executable
        final exeDir = path.dirname(Platform.resolvedExecutable);
        final bridgeExe = path.join(exeDir, 'bridge_backend.exe');

        if (!await File(bridgeExe).exists()) {
          throw Exception(
              'Erro de Instalação: O motor forense (bridge_backend.exe) não foi encontrado na pasta do sistema.');
        }

        executable = bridgeExe;
        arguments = [
          '--json',
          evidenceJsonPath,
          '--out',
          outputDir,
        ];
      } else {
        // Debug Mode: Use configured Python path
        if (kDebugMode) {
          print('🚀 [FLUTTER] Iniciando execução do Python (DEBUG)...');
          print('   Python: $pythonPath');
          print('   Script: $scriptPath');
          print('   JSON: $evidenceJsonPath');
          print('   Out: $outputDir');
        }

        // Verify files exist
        if (!await File(pythonPath).exists()) {
          throw Exception('Executável Python não encontrado: $pythonPath');
        }
        if (!await File(scriptPath).exists()) {
          throw Exception('Script Python não encontrado: $scriptPath');
        }

        executable = pythonPath;
        arguments = [
          scriptPath,
          '--json',
          evidenceJsonPath,
          '--out',
          outputDir,
        ];
      }

      final result = await Process.run(
        executable,
        arguments,
        runInShell: true,
      );

      // Log stdout
      if (result.stdout.toString().isNotEmpty) {
        if (kDebugMode) print('🐍 [PYTHON STDOUT]:\n${result.stdout}');
      }

      // Log stderr
      if (result.stderr.toString().isNotEmpty) {
        if (kDebugMode) print('❌ [PYTHON STDERR]:\n${result.stderr}');
      }

      if (result.exitCode == 0) {
        return true;
      } else {
        final errorMsg =
            'Python falhou com código ${result.exitCode}.\nStderr: ${result.stderr}';
        if (kDebugMode) print('⚠️ [FLUTTER] $errorMsg');

        if (kReleaseMode) {
          await _logErrorToDocuments(errorMsg);
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ [FLUTTER] Erro ao chamar Python: $e');
      if (kReleaseMode) {
        await _logErrorToDocuments('Erro crítico ao chamar Python: $e');
      }
      rethrow;
    }
  }

  Future<void> _logErrorToDocuments(String error) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final logFile = File(path.join(docsDir.path, 'error_log.txt'));
      final timestamp = DateTime.now().toIso8601String();
      await logFile.writeAsString(
        '[$timestamp] $error\n-----------------------------------\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Fail silently if logging fails
    }
  }

  Future<String> createJobData(Map<String, dynamic> data) async {
    final tempDir = await getTemporaryDirectory();
    final jobFile = File(path.join(tempDir.path,
        'job_data_${DateTime.now().millisecondsSinceEpoch}.json'));
    await jobFile.writeAsString(jsonEncode(data));
    return jobFile.path;
  }
}
