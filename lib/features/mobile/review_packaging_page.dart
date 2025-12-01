import 'package:flutter/material.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'collection_page.dart'; // Import for PhotoSlot
import 'services/case_repository.dart';
import 'services/mobile_archive_service.dart';

class ReviewPackagingPage extends StatefulWidget {
  final List<PhotoSlot> slots;
  final String bop;
  final String type;

  const ReviewPackagingPage({
    super.key,
    required this.slots,
    required this.bop,
    required this.type,
  });

  @override
  State<ReviewPackagingPage> createState() => _ReviewPackagingPageState();
}

class _ReviewPackagingPageState extends State<ReviewPackagingPage> {
  // Tailwind Colors
  static const Color bgDark = Color(0xFF111827); // gray-900
  static const Color cardDark = Color(0xFF1F2937); // gray-800
  static const Color textWhite = Color(0xFFF9FAFB); // gray-50
  static const Color textGray = Color(0xFF9CA3AF); // gray-400
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color amber500 = Color(0xFFF59E0B);

  bool _isSealing = false;
  final _repository = CaseRepository();
  final _archiveService = MobileArchiveService();

  Future<void> _sealPackage() async {
    setState(() {
      _isSealing = true;
    });

    try {
      // Generate Case Metadata
      final caseId = const Uuid().v4().substring(0, 8);
      final bop = widget.bop;
      final type = widget.type;

      // 1. Create ZIP Package
      final zipPath = await _archiveService.createCasePackage(
        caseId: caseId,
        bop: bop,
        type: type,
        slots: widget.slots,
      );

      // 2. Calculate Package Hash
      final file = File(zipPath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      final packageHash = digest.toString();

      // 3. Save to Repository
      final newCase = {
        'id': caseId,
        'bop': bop,
        'type': type,
        'crime': 'Furto', // Mock for now
        'status': 'ready',
        'zipPath': zipPath,
        'hash': packageHash,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _repository.saveCase(newCase);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: cardDark,
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: emerald500, size: 48),
              SizedBox(height: 16),
              Text('Pacote Lacrado!', style: TextStyle(color: textWhite)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Todas as evidências foram validadas e o pacote digital foi gerado com sucesso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textGray),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: emerald500.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Hash do Pacote (SHA-256)',
                        style: TextStyle(
                            color: emerald500,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      packageHash,
                      style: const TextStyle(
                          color: textWhite,
                          fontFamily: 'monospace',
                          fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Salvo em: $zipPath',
                style: const TextStyle(color: textGray, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close ReviewPage
                  Navigator.pop(
                      context); // Close CollectionPage -> Back to Dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyan500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Voltar ao Início',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao lacrar pacote: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSealing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Text(
          'Revisão e Lacração',
          style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isSealing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: cyan500),
                  const SizedBox(height: 24),
                  const Text(
                    'Gerando Pacote Digital...',
                    style: TextStyle(
                        color: textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculando hashes e criptografando dados',
                    style: TextStyle(color: textGray.withOpacity(0.8)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.slots.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final slot = widget.slots[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF374151)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: slot.imageUrl != null
                                  ? Image.file(
                                      File(slot.imageUrl!),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.black,
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: textGray),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.name,
                                    style: const TextStyle(
                                        color: textWhite,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.lock,
                                          size: 12, color: emerald500),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          slot.hash ?? 'Hash pendente',
                                          style: const TextStyle(
                                              color: textGray,
                                              fontSize: 10,
                                              fontFamily: 'monospace'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (slot.observation != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.mic,
                                              size: 12, color: amber500),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Contém observação',
                                            style: TextStyle(
                                                color: amber500, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle,
                                color: emerald500, size: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardDark,
                    border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: textGray, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ao lacrar, não será possível alterar os dados.',
                              style: TextStyle(
                                  color: textGray.withOpacity(0.8),
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _sealPackage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: emerald500,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Lacrar Pacote Digital',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
