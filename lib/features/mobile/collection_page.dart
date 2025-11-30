import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:image_picker/image_picker.dart';

class GuidedCollectionPage extends StatefulWidget {
  const GuidedCollectionPage({super.key});

  @override
  State<GuidedCollectionPage> createState() => _GuidedCollectionPageState();
}

class _GuidedCollectionPageState extends State<GuidedCollectionPage> {
  // Tailwind Colors
  static const Color bgDark = Color(0xFF111827); // gray-900
  static const Color cardDark = Color(0xFF1F2937); // gray-800
  static const Color textWhite = Color(0xFFF9FAFB); // gray-50
  static const Color textGray = Color(0xFF9CA3AF); // gray-400
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color red500 = Color(0xFFEF4444);

  List<PhotoSlot> slots = [
    PhotoSlot(id: 1, name: 'Pacote Lacrado', required: true),
    PhotoSlot(id: 2, name: 'Lacre Rompido', required: true),
    PhotoSlot(id: 3, name: 'Vista Frontal', required: true),
    PhotoSlot(id: 4, name: 'Vista Traseira (IMEI)', required: true),
    PhotoSlot(id: 5, name: 'Gaveta SIM Card', required: false),
  ];

  int? expandedSlotId;
  int? recordingAudioId;
  bool showAddPhotoDialog = false;
  final TextEditingController _customPhotoController = TextEditingController();

  Future<void> _capturePhoto(int slotId) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) return;

      setState(() {
        slots = slots.map((slot) {
          if (slot.id == slotId) {
            return slot.copyWith(
              capturing: false,
              validating: true,
              imageUrl: image.path,
            );
          }
          return slot;
        }).toList();
      });

      // Simulate hash generation (1.5 seconds)
      Timer(const Duration(milliseconds: 1500), () {
        final hash = _generateHash();
        setState(() {
          slots = slots.map((slot) {
            if (slot.id == slotId) {
              return slot.copyWith(
                validating: false,
                captured: true,
                hash: hash,
              );
            }
            return slot;
          }).toList();
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao capturar foto: $e')),
      );
    }
  }

  String _generateHash() {
    const chars = '0123456789abcdef';
    final rnd = Random();
    return List.generate(64, (index) => chars[rnd.nextInt(chars.length)])
        .join();
  }

  void _toggleAudioRecording(int slotId) {
    setState(() {
      if (recordingAudioId == slotId) {
        recordingAudioId = null;
        slots = slots.map((slot) {
          if (slot.id == slotId) {
            return slot.copyWith(observation: 'Observação gravada via áudio');
          }
          return slot;
        }).toList();
      } else {
        recordingAudioId = slotId;
      }
    });
  }

  void _addCustomPhoto() {
    if (_customPhotoController.text.trim().isEmpty) return;

    final newId = slots.map((s) => s.id).reduce(max) + 1;
    final newSlot = PhotoSlot(
      id: newId,
      name: _customPhotoController.text.trim(),
      required: false,
      isCustom: true,
    );

    setState(() {
      slots.add(newSlot);
      _customPhotoController.clear();
      showAddPhotoDialog = false;
    });
  }

  void _deleteCustomSlot(int slotId) {
    setState(() {
      slots.removeWhere((slot) => slot.id == slotId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final requiredSlots = slots.where((s) => s.required).toList();
    final capturedRequired = requiredSlots.where((s) => s.captured).length;
    final customSlots = slots.where((s) => s.isCustom).toList();
    final progress =
        requiredSlots.isEmpty ? 0.0 : capturedRequired / requiredSlots.length;
    final canFinalize = capturedRequired == requiredSlots.length;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coleta Guiada',
              style: TextStyle(
                  color: textWhite, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 2),
            Text(
              'Modelo: Celular / Smartphone',
              style: TextStyle(
                  color: textGray, fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progresso da Coleta',
                        style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Text(
                            '$capturedRequired/${requiredSlots.length} obrigatórias',
                            style: const TextStyle(
                              color: cyan500,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (customSlots.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '+ ${customSlots.where((s) => s.captured).length}/${customSlots.length} extras',
                              style: const TextStyle(
                                color: textGray,
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: bgDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 12,
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [cyan500, emerald500],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (canFinalize) ...[
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: emerald500, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Todas as fotos obrigatórias capturadas!',
                          style: TextStyle(color: emerald500, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Slots List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final slot = slots[index];
                return _buildEvidenceCard(slot);
              },
            ),

            const SizedBox(height: 24),

            // Add Custom Photo Button
            if (!showAddPhotoDialog)
              InkWell(
                onTap: () => setState(() => showAddPhotoDialog = true),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF374151), // gray-700
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: amber500.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: amber500, size: 24),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Adicionar Foto Extra',
                        style: TextStyle(
                            color: amber500,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Adicione fotos complementares além das obrigatórias',
                        style: TextStyle(color: textGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: amber500.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: amber500.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nova Foto Extra',
                      style: TextStyle(
                          color: amber500,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dê um nome descritivo para esta foto (ex: "Dano na Tela", "Chip Encontrado")',
                      style: TextStyle(color: textGray, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customPhotoController,
                      style: const TextStyle(color: textWhite),
                      decoration: InputDecoration(
                        hintText: 'Nome da foto...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF374151)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF374151)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: amber500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                showAddPhotoDialog = false;
                                _customPhotoController.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: textGray),
                              ),
                            ),
                            child: const Text('Cancelar',
                                style: TextStyle(color: textWhite)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addCustomPhoto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: amber500,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Adicionar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Voltar',
                          style: TextStyle(color: textWhite)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canFinalize
                          ? () {
                              // Navigate to review
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emerald500,
                        disabledBackgroundColor:
                            const Color(0xFF064E3B), // emerald-900
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              size: 18,
                              color: canFinalize
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 8),
                          Text(
                            'Finalizar Coleta',
                            style: TextStyle(
                              color: canFinalize
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(PhotoSlot slot) {
    Color borderColor = Colors.transparent;
    if (slot.captured) {
      borderColor = emerald500.withOpacity(0.5);
    } else if (slot.capturing || slot.validating) {
      borderColor = cyan500;
    } else if (slot.isCustom) {
      borderColor = amber500.withOpacity(0.3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: borderColor == Colors.transparent ? cardDark : borderColor,
            width: slot.capturing || slot.validating ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: slot.captured
                          ? emerald500
                          : (slot.capturing || slot.validating)
                              ? cyan500
                              : slot.isCustom
                                  ? amber500.withOpacity(0.2)
                                  : const Color(0xFF374151),
                      shape: BoxShape.circle,
                      border: slot.isCustom && !slot.captured
                          ? Border.all(
                              color: amber500.withOpacity(0.5), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: slot.captured
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 22)
                          : Text(
                              '${slot.id}',
                              style: TextStyle(
                                color: slot.isCustom ? amber500 : textGray,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            slot.name,
                            style: const TextStyle(
                                color: textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                          if (slot.required)
                            const Text(' *',
                                style: TextStyle(
                                    color: red500,
                                    fontWeight: FontWeight.bold)),
                          if (slot.isCustom)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: amber500.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Extra',
                                style: TextStyle(
                                    color: amber500,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${slot.required ? 'Obrigatória' : 'Opcional'}${slot.observation != null ? ' • Com observação' : ''}',
                        style: const TextStyle(color: textGray, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (slot.captured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: emerald500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, size: 12, color: emerald500),
                          SizedBox(width: 4),
                          Text('Validado',
                              style: TextStyle(
                                  color: emerald500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  if (slot.isCustom && !slot.captured)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: red500, size: 20),
                      onPressed: () => _deleteCustomSlot(slot.id),
                      style: IconButton.styleFrom(
                        backgroundColor: red500.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Content based on state
          if (slot.capturing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cyan500, width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.camera_alt, size: 48, color: cyan500),
                  SizedBox(height: 12),
                  Text('Capturando imagem...',
                      style: TextStyle(
                          color: cyan500, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else if (slot.validating)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cyan500, width: 2),
              ),
              child: Column(
                children: [
                  // Placeholder for image during validation
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: slot.imageUrl != null &&
                                File(slot.imageUrl!).existsSync()
                            ? FileImage(File(slot.imageUrl!)) as ImageProvider
                            : NetworkImage(slot.imageUrl ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: cyan500.withOpacity(0.2),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: bgDark.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: cyan500),
                              ),
                              SizedBox(width: 12),
                              Text('Gerando hash SHA-256...',
                                  style: TextStyle(
                                      color: cyan500,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (slot.captured)
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedSlotId =
                          expandedSlotId == slot.id ? null : slot.id;
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        slot.imageUrl != null &&
                                File(slot.imageUrl!).existsSync()
                            ? Image.file(
                                File(slot.imageUrl!),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                slot.imageUrl ?? '',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                        if (expandedSlotId == slot.id)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                              child: const Center(
                                child: Icon(Icons.zoom_in,
                                    color: Colors.white, size: 32),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hash SHA-256:',
                              style: TextStyle(
                                  color: textGray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              Icon(Icons.lock, size: 12, color: emerald500),
                              SizedBox(width: 4),
                              Text('Integridade Garantida',
                                  style: TextStyle(
                                      color: emerald500, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot.hash ?? '',
                        style: const TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontFamily: 'monospace',
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleAudioRecording(slot.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: recordingAudioId == slot.id
                              ? red500
                              : slot.observation != null
                                  ? emerald500.withOpacity(0.2)
                                  : const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: slot.observation != null
                                ? emerald500.withOpacity(0.3)
                                : const Color(0xFF374151),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic,
                                size: 16,
                                color: recordingAudioId == slot.id
                                    ? Colors.white
                                    : (slot.observation != null
                                        ? emerald500
                                        : textGray)),
                            const SizedBox(width: 8),
                            Text(
                              recordingAudioId == slot.id
                                  ? 'Gravando...'
                                  : slot.observation != null
                                      ? 'Observação adicionada'
                                      : 'Adicionar observação',
                              style: TextStyle(
                                color: recordingAudioId == slot.id
                                    ? Colors.white
                                    : (slot.observation != null
                                        ? emerald500
                                        : textGray),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (slot.observation != null &&
                        recordingAudioId != slot.id) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon:
                            const Icon(Icons.close, size: 16, color: textGray),
                        onPressed: () {
                          setState(() {
                            slots = slots.map((s) {
                              if (s.id == slot.id) {
                                return s.copyWith(
                                    observation: null); // Clear observation
                              }
                              return s;
                            }).toList();
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF374151),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ],
                ),
                if (slot.observation != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF374151)),
                    ),
                    child: Text(
                      slot.observation!,
                      style: const TextStyle(
                          color: Color(0xFFD1D5DB), fontSize: 14),
                    ),
                  ),
                ],
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _capturePhoto(slot.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyan500,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Capturar Foto',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PhotoSlot {
  final int id;
  final String name;
  final bool required;
  final bool captured;
  final bool capturing;
  final bool validating;
  final String? imageUrl;
  final String? hash;
  final String? observation;
  final bool isCustom;

  PhotoSlot({
    required this.id,
    required this.name,
    required this.required,
    this.captured = false,
    this.capturing = false,
    this.validating = false,
    this.imageUrl,
    this.hash,
    this.observation,
    this.isCustom = false,
  });

  PhotoSlot copyWith({
    int? id,
    String? name,
    bool? required,
    bool? captured,
    bool? capturing,
    bool? validating,
    String? imageUrl,
    String? hash,
    String? observation, // Allow null to clear
    bool? isCustom,
  }) {
    return PhotoSlot(
      id: id ?? this.id,
      name: name ?? this.name,
      required: required ?? this.required,
      captured: captured ?? this.captured,
      capturing: capturing ?? this.capturing,
      validating: validating ?? this.validating,
      imageUrl: imageUrl ?? this.imageUrl,
      hash: hash ?? this.hash,
      observation: observation, // Pass directly to allow null
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
