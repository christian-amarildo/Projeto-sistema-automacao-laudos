import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'import_state.dart';
import 'inspection_page.dart';

class DropzonePage extends ConsumerStatefulWidget {
  const DropzonePage({super.key});

  @override
  ConsumerState<DropzonePage> createState() => _DropzonePageState();
}

class _DropzonePageState extends ConsumerState<DropzonePage> {
  bool _dragging = false;

  void _handleFile(File file) {
    if (file.path.endsWith('.zip') || file.path.endsWith('.fcase')) {
      ref.read(importControllerProvider.notifier).importCase(file);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato inválido. Use .zip ou .fcase'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'fcase'],
    );

    if (result != null && result.files.single.path != null) {
      _handleFile(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importControllerProvider);

    // Navigation listener
    ref.listen(importControllerProvider, (previous, next) {
      if (next.caseModel != null && !next.isLoading && next.error == null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const InspectionPage()),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: ${next.error}'),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // bg-gray-900
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Área de Trabalho',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DropTarget(
                onDragDone: (detail) {
                  if (detail.files.isNotEmpty) {
                    _handleFile(File(detail.files.first.path));
                  }
                },
                onDragEntered: (detail) => setState(() => _dragging = true),
                onDragExited: (detail) => setState(() => _dragging = false),
                child: InkWell(
                  onTap: importState.isLoading ? null : _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _dragging
                          ? const Color(0xFF06B6D4).withOpacity(0.1)
                          : const Color(0xFF1F2937), // gray-800
                      border: Border.all(
                        color: _dragging
                            ? const Color(0xFF06B6D4)
                            : const Color(0xFF374151), // gray-700
                        width: 2,
                        style: BorderStyle
                            .solid, // Dashed border needs a custom painter, solid for now or use dotted_border package if requested
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (importState.isLoading) ...[
                          const SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                                color: Color(0xFF06B6D4)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Carregando arquivo...',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Aguarde enquanto validamos o pacote',
                            style:
                                TextStyle(color: Color(0xFF9CA3AF)), // gray-400
                          ),
                        ] else ...[
                          const Icon(Icons.upload_file,
                              size: 64, color: Color(0xFF4B5563)), // gray-600
                          const SizedBox(height: 16),
                          const Text(
                            'Arraste o arquivo aqui',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Solte o arquivo .zip ou .fcase para iniciar a validação',
                            style:
                                TextStyle(color: Color(0xFF9CA3AF)), // gray-400
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Selecionar Arquivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF06B6D4), // cyan-500
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Formatos aceitos: .zip, .fcase | Tamanho máximo: 500 MB',
                            style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12), // gray-500
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
