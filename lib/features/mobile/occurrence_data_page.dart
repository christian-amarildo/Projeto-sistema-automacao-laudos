import 'package:flutter/material.dart';
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

  void _handleScan() {
    setState(() => _scanning = true);
    // Simulate OCR delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _bopController.text = '00615/2023.101174-7';
          _protocolController.text = '2025.01.090674';
          _requisitionController.text = '00001-2025-126567-6';
          _crimeTypeController.text =
              'Estelionato > Estelionato simples (Art 171)';
          _policeStationController.text =
              'DIVISÃO DE COMBATE A CRIMES CIBERNÉTICOS';
          _requestingAuthorityController.text = 'TOBIAS FERREIRA RODRIGUES';
          _requestDateTimeController.text = '24/11/2025 15:44:08';
          _caseNumberController.text = '2025.056800';
          _occurrenceLocationController.text = 'INTERNET';
          _addressController.text = 'AZ DE OURO, N. 87, LEVILÂNDIA, ANANINDEUA';
          _forensicAreaController.text = 'AUDIOVISUAL / ANÁLISE DE CONTEÚDO';
          _additionalInfoController.text =
              'REALIZAR PERÍCIA EM LOCAL DE INTERNET';
          _scanning = false;
        });
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
                                  builder: (context) =>
                                      const GuidedCollectionPage()),
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
