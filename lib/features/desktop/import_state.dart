import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/case_model.dart';
import '../../shared/services/archive_service.dart';
import '../../shared/services/hash_service.dart';
import 'package:path/path.dart' as path;

class EvidenceFile {
  final String name;
  final String path;
  final String originalHash;
  final String? currentHash;
  final bool isValid;
  final bool isChecking;

  EvidenceFile({
    required this.name,
    required this.path,
    required this.originalHash,
    this.currentHash,
    this.isValid = false,
    this.isChecking = false,
  });

  EvidenceFile copyWith({
    String? name,
    String? path,
    String? originalHash,
    String? currentHash,
    bool? isValid,
    bool? isChecking,
  }) {
    return EvidenceFile(
      name: name ?? this.name,
      path: path ?? this.path,
      originalHash: originalHash ?? this.originalHash,
      currentHash: currentHash ?? this.currentHash,
      isValid: isValid ?? this.isValid,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class ImportedCaseState {
  final CaseModel? caseModel;
  final List<EvidenceFile> evidenceFiles;
  final bool isLoading;
  final String? error;
  final bool isIntegrityValid;

  ImportedCaseState({
    this.caseModel,
    this.evidenceFiles = const [],
    this.isLoading = false,
    this.error,
    this.isIntegrityValid = false,
  });

  ImportedCaseState copyWith({
    CaseModel? caseModel,
    List<EvidenceFile>? evidenceFiles,
    bool? isLoading,
    String? error,
    bool? isIntegrityValid,
  }) {
    return ImportedCaseState(
      caseModel: caseModel ?? this.caseModel,
      evidenceFiles: evidenceFiles ?? this.evidenceFiles,
      isLoading: isLoading ?? this.isLoading,
      error:
          error, // Allow clearing error by passing null, but here we usually pass a new error or null
      isIntegrityValid: isIntegrityValid ?? this.isIntegrityValid,
    );
  }
}

class ImportController extends StateNotifier<ImportedCaseState> {
  final ArchiveService _archiveService;
  final HashService _hashService;

  ImportController(this._archiveService, this._hashService)
      : super(ImportedCaseState());

  Future<void> importCase(File zipFile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Extract
      final extractionPath = await _archiveService.extractPackage(zipFile);

      // 2. Read Manifest
      final manifest = await _archiveService.readManifest(extractionPath);
      final caseModel = CaseModel.fromJson(manifest['case']);
      final evidenceList =
          (manifest['evidence'] as List).cast<Map<String, dynamic>>();

      // 3. Prepare Evidence Files
      List<EvidenceFile> files = [];
      for (var ev in evidenceList) {
        files.add(EvidenceFile(
          name: ev['name'],
          path: path.join(extractionPath,
              ev['fileName']), // Assuming fileName is in manifest
          originalHash: ev['hash'],
          isChecking: true,
        ));
      }

      state = state.copyWith(
        caseModel: caseModel,
        evidenceFiles: files,
      );

      // 4. Validate Integrity
      await _validateIntegrity(files);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _validateIntegrity(List<EvidenceFile> files) async {
    List<EvidenceFile> validatedFiles = [];
    bool allValid = true;

    for (var file in files) {
      final physicalFile = File(file.path);
      if (await physicalFile.exists()) {
        final currentHash = await _hashService.calculateFileHash(physicalFile);
        final isValid = currentHash == file.originalHash;

        if (!isValid) allValid = false;

        validatedFiles.add(file.copyWith(
          currentHash: currentHash,
          isValid: isValid,
          isChecking: false,
        ));
      } else {
        allValid = false;
        validatedFiles.add(file.copyWith(
          isValid: false,
          isChecking: false,
          currentHash: 'File not found',
        ));
      }

      // Update state incrementally if needed, or batch at the end
      // state = state.copyWith(evidenceFiles: [...validatedFiles, ...remaining]);
    }

    state = state.copyWith(
      evidenceFiles: validatedFiles,
      isLoading: false,
      isIntegrityValid: allValid,
    );
  }

  void clear() {
    state = ImportedCaseState();
  }
}

final archiveServiceProvider = Provider((ref) => ArchiveService());
final hashServiceProvider = Provider((ref) => HashService());

final importControllerProvider =
    StateNotifierProvider<ImportController, ImportedCaseState>((ref) {
  return ImportController(
    ref.watch(archiveServiceProvider),
    ref.watch(hashServiceProvider),
  );
});
