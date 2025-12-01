import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'collection_page.dart';

class OccurrenceDataPage extends StatefulWidget {
  const OccurrenceDataPage({super.key});

  @override
  State<OccurrenceDataPage> createState() => _OccurrenceDataPageState();
}

class _OccurrenceDataPageState extends State<OccurrenceDataPage> {
  bool _scanning = false;
  String _model = '';

  // Controllers
  final _bopController = TextEditingController();
  final _protocolController = TextEditingController();
  final _requisitionController = TextEditingController();
  final _crimeTypeController = TextEditingController();
  final _policeStationController = TextEditingController();
  final _requestingAuthorityController = TextEditingController();
  final _requestDateTimeController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _occurrenceLocationController = TextEditingController();
  final _addressController = TextEditingController();
  final _forensicAreaController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  Future<void> _handleScan() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      setState(() => _scanning = true);

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      _parseOcrText(recognizedText.text);

      await textRecognizer.close();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no OCR: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  void _parseOcrText(String text) {
    // Normalize text to uppercase for easier matching
    final upperText = text.toUpperCase();

    // Helper to extract value using Regex
    String? extract(String pattern) {
      final regex = RegExp(pattern, multiLine: true, dotAll: true);
      final match = regex.firstMatch(upperText);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
      return null;
    }

    setState(() {
      // 1. Requisição (REQUISIÇÃO ONLINE DE PERÍCIA - Nº ...)
      // Uses . for accented characters to be more robust (PER.CIA)
      final reqMatch = extract(r'REQUISI..O.*PER.CIA.*N[ºo°]\s*([\d-]+)');
      if (reqMatch != null) _requisitionController.text = reqMatch;

      // 2. Inquérito/BOP (INQUÉRITO POR PORTARIA/FLAGRANTE nº ...)
      final bopMatch = extract(r'INQU.RITO.*N[ºo°]\s*([\d./-]+)');
      if (bopMatch != null) _bopController.text = bopMatch;

      // 3. Identificação do Fato (Tipo de Crime)
      final crimeMatch = extract(r'IDENTIFICA..O DO FATO:\s*(.*)');
      if (crimeMatch != null) _crimeTypeController.text = crimeMatch;

      // 4. Unidade Requisitante (Delegacia)
      final unitMatch = extract(r'UNIDADE REQUISITANTE:\s*(.*)');
      if (unitMatch != null) _policeStationController.text = unitMatch;

      // 5. Número do Caso
      final caseMatch = extract(r'N.MERO DO CASO:\s*([\d.]+)');
      if (caseMatch != null) _caseNumberController.text = caseMatch;

      // 6. Número do Protocolo
      final protocolMatch = extract(r'N.MERO DO PROTOCOLO:\s*([\d.]+)');
      if (protocolMatch != null) _protocolController.text = protocolMatch;

      // 7. Autoridade Requisitante
      final authMatch = extract(r'AUTORIDADE REQUISITANTE:\s*(.*)');
      if (authMatch != null) _requestingAuthorityController.text = authMatch;

      // 8. Local de Ocorrência
      final localMatch = extract(r'LOCAL DE OCORR.NCIA:\s*(.*)');
      if (localMatch != null) _occurrenceLocationController.text = localMatch;

      // 9. Endereço do Fato/Perícia
      final addressMatch = extract(r'ENDERE.O DO FATO/PER.CIA:\s*(.*)');
      if (addressMatch != null) _addressController.text = addressMatch;

      // 10. Área Pericial
      final areaMatch = extract(r'.REA PERICIAL / EXAME:\s*(.*)');
      if (areaMatch != null) _forensicAreaController.text = areaMatch;

      // 11. Data/Hora Requisição
      final dateMatch = extract(r'DATA/HORA REQUISI..O:\s*([\d/ :]+)');
      if (dateMatch != null) _requestDateTimeController.text = dateMatch;

      // 12. Informações Adicionais (Observações)
      final infoMatch =
          extract(r'INFORMA..ES ADICIONAIS:\s*([\s\S]*?)(?:ASSINATURAS:|$)');
      if (infoMatch != null) {
        _additionalInfoController.text = infoMatch.replaceAll('\n', ' ').trim();
      }

      // Auto-select model based on keywords
      final fullContext = (infoMatch ?? '') + (areaMatch ?? '');
      if (fullContext.contains('CELULAR') ||
          fullContext.contains('SMARTPHONE') ||
          fullContext.contains('MOTOROLA') ||
          fullContext.contains('SAMSUNG') ||
          fullContext.contains('IPHONE')) {
        _model = 'celular';
      } else if (fullContext.contains('COMPUTADOR') ||
          fullContext.contains('NOTEBOOK') ||
          fullContext.contains('LAPTOP')) {
        _model = 'computador';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // gray-900
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados da Ocorrência',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              'Preencha ou escaneie a requisição',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9CA3AF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OCR Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.document_scanner,
                      color: Color(0xFF22D3EE), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OCR Inteligente',
                          style: TextStyle(
                            color: Color(0xFF22D3EE),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fotografe a requisição e o sistema preencherá automaticamente os campos',
                          style:
                              TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _scanning ? null : _handleScan,
                          icon: _scanning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.camera_alt, size: 16),
                          label: Text(_scanning
                              ? 'Processando...'
                              : 'Escanear Requisição'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Required Fields
            _buildSectionHeader('Dados Obrigatórios'),
            _buildInput(
                'BOP / Ocorrência *', '00000/0000.000000-0', _bopController),
            _buildInput('Protocolo *', '0000.00.000000', _protocolController),
            _buildInput(
                'Requisição *', '00000-0000-000000-0', _requisitionController),

            const SizedBox(height: 16),
            const Text(
              'Modelo de Perícia *',
              style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _model.isEmpty ? null : _model,
                  hint: const Text('Selecione o tipo de perícia',
                      style: TextStyle(color: Color(0xFF6B7280))),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1F2937),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                        value: 'celular',
                        child: Text('📱 Celular / Smartphone')),
                    DropdownMenuItem(
                        value: 'computador',
                        child: Text('💻 Computador / Notebook')),
                    DropdownMenuItem(
                        value: 'hd', child: Text('💾 HD / Disco Rígido')),
                    DropdownMenuItem(
                        value: 'pendrive',
                        child: Text('🔌 Pendrive / Cartão SD')),
                    DropdownMenuItem(
                        value: 'local', child: Text('🌐 Local de Internet')),
                  ],
                  onChanged: (value) => setState(() => _model = value!),
                ),
              ),
            ),

            if (_model.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFFFBBF24), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'O modelo de perícia define quais fotos serão solicitadas na próxima etapa',
                        style:
                            TextStyle(color: Color(0xFFFCD34D), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Optional Fields
            _buildSectionHeader('Dados Complementares (Opcional)'),
            _buildInput(
                'Tipo de Crime', 'Ex: Estelionato', _crimeTypeController),
            _buildInput('Delegacia', 'Ex: Divisão de Cibernéticos',
                _policeStationController),
            _buildInput('Autoridade', 'Ex: Nome do delegado',
                _requestingAuthorityController),
            _buildInput(
                'Data/Hora', 'DD/MM/AAAA HH:MM:SS', _requestDateTimeController),
            _buildInput('Número do Caso', '0000.000000', _caseNumberController),
            _buildInput('Local', 'Ex: Internet', _occurrenceLocationController),
            _buildInput('Endereço', 'Rua, número...', _addressController),
            _buildInput(
                'Área Pericial', 'Ex: Audiovisual', _forensicAreaController),

            const SizedBox(height: 16),
            const Text(
              'Observações',
              style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _additionalInfoController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Descrição detalhada...',
                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF1F2937),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF374151)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_model.isEmpty || _bopController.text.isEmpty)
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GuidedCollectionPage(
                                  bop: _bopController.text,
                                  model: _model,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF374151),
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Avançar para Coleta'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFF374151))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _buildInput(
      String label, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() {}), // Rebuild to validate
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              filled: true,
              fillColor: const Color(0xFF1F2937),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF374151)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF374151)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF06B6D4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
