import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'import_state.dart';
import 'settings_page.dart';
import '../../shared/services/python_bridge_service.dart';

class InspectionPage extends ConsumerWidget {
  const InspectionPage({super.key});

  Future<void> _processCase(BuildContext context, WidgetRef ref) async {
    final importState = ref.read(importControllerProvider);
    if (importState.caseModel == null) return;

    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1F2937),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF06B6D4)),
            SizedBox(height: 16),
            Text('🤖 A IA está gerando o laudo...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final pythonPath =
          prefs.getString('python_path') ?? r'C:\Python39\python.exe';
      final scriptPath = prefs.getString('script_path') ?? '';
      final outputDir =
          prefs.getString('output_dir') ?? r'C:\ForensiChain\Laudos';

      if (scriptPath.isEmpty) {
        throw Exception(
            'Caminho do script não configurado. Vá em Configurações.');
      }

      // Prepare Data
      final jobData = {
        'cabecalho': importState.caseModel!.toJson(),
        'evidencias': importState.evidenceFiles
            .map((e) => {
                  'id': e.name, // Using name as ID for now
                  'caminho_local': e.path,
                  'label': e.name,
                  'validado': e.isValid,
                  'hash': e.currentHash,
                })
            .toList(),
      };

      final bridge = PythonBridgeService();
      final jsonPath = await bridge.createJobData(jobData);

      final success = await bridge.executeAutomation(
        pythonPath: pythonPath,
        scriptPath: scriptPath,
        evidenceJsonPath: jsonPath,
        outputDir: outputDir,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close Loading
      }

      if (success && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: const Text('Missão Cumprida! 🎉',
                style: TextStyle(color: Color(0xFF10B981))),
            content: const Text('O laudo foi gerado com sucesso.',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Open folder logic (future)
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4)),
                child: const Text('Abrir Pasta',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else if (context.mounted) {
        throw Exception('O script Python retornou erro. Verifique o console.');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close Loading if open

        final isInstallationError = e.toString().contains('Erro de Instalação');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: Text(
              isInstallationError ? 'Erro Fatal' : 'Erro',
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(importControllerProvider);
    final caseModel = importState.caseModel;
    final evidenceFiles = importState.evidenceFiles;
    final isIntegrityValid = importState.isIntegrityValid;

    if (caseModel == null) {
      return const Scaffold(
        body: Center(child: Text('Nenhum caso importado.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // bg-gray-900
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 300,
            color: const Color(0xFF1F2937), // bg-gray-800
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Casos Recentes',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Mock Recent Cases List
                _buildRecentCaseItem(
                    '12347/2025.000003-0', '15/01/2025 14:32', 'Processado'),
                _buildRecentCaseItem(
                    '12346/2025.000002-0', '15/01/2025 11:18', 'Processado'),
                _buildRecentCaseItem(
                    '12345/2025.000001-0', '14/01/2025 16:45', 'Processado'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Configurações'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9CA3AF),
                      side: const BorderSide(color: Color(0xFF374151)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9CA3AF),
                      side: const BorderSide(color: Color(0xFF374151)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Ver Todos os Casos'),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Integrity Status Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isIntegrityValid
                          ? const Color(0xFF10B981)
                              .withOpacity(0.1) // emerald-500/10
                          : const Color(0xFFEF4444)
                              .withOpacity(0.1), // red-500/10
                      border: Border.all(
                        color: isIntegrityValid
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isIntegrityValid ? Icons.check_circle : Icons.warning,
                          color: isIntegrityValid
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isIntegrityValid
                                    ? 'Cadeia de Custódia VÁLIDA'
                                    : 'VIOLAÇÃO DETECTADA',
                                style: TextStyle(
                                  color: isIntegrityValid
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isIntegrityValid
                                    ? 'Todos os hashes foram verificados e correspondem aos originais'
                                    : 'A integridade da evidência foi comprometida. Verifique os itens abaixo.',
                                style: TextStyle(
                                  color: isIntegrityValid
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(
                                          0xFFFCA5A5), // emerald-300 : red-300
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Case Data
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dados Extraídos',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit,
                                  size: 16, color: Color(0xFF9CA3AF)),
                              label: const Text('Editar',
                                  style: TextStyle(color: Color(0xFF9CA3AF))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildInfoField('BOP / Ocorrência',
                                '12345/2025.000001-0'), // Mocked for now as CaseModel might not have all fields yet
                            _buildInfoField('Protocolo', '2025.01.150001'),
                            _buildInfoField(
                                'Requisição', '15001-2025-000001-0'),
                            _buildInfoField('Perito Responsável',
                                'João Silva - Mat. 12345'),
                            _buildInfoField(
                                'Data da Coleta', '15/01/2025 14:23'),
                            _buildInfoField(
                                'Modelo de Perícia', 'Celular / Smartphone'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Evidence Grid
                  const Text(
                    'Validação de Evidências',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: evidenceFiles.length,
                    itemBuilder: (context, index) {
                      final file = evidenceFiles[index];
                      return _buildEvidenceCard(file);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Bottom Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(importControllerProvider.notifier).clear();
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                        child: const Text('Voltar',
                            style: TextStyle(color: Color(0xFF9CA3AF))),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF9CA3AF),
                              side: const BorderSide(color: Color(0xFF374151)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),
                            child:
                                const Text('Exportar Relatório de Validação'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: isIntegrityValid
                                ? () => _processCase(context, ref)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06B6D4),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF374151),
                              disabledForegroundColor: const Color(0xFF9CA3AF),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),
                            child: const Text('Prosseguir para Geração'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCaseItem(String bop, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bop,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(date,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF374151)),
          ),
          child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildEvidenceCard(EvidenceFile file) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(4),
              image: file.path.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(file.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: file.path.isEmpty
                ? const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Color(0xFF4B5563)))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text('Hash SHA-256:',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                Text(
                  file.currentHash ?? 'Calculando...',
                  style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontFamily: 'monospace',
                      fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      file.isValid ? Icons.check_circle : Icons.warning,
                      color: file.isValid
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      file.isValid ? 'Hash Verificado' : 'Hash Inválido',
                      style: TextStyle(
                        color: file.isValid
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
