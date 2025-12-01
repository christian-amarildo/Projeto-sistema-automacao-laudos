import 'package:flutter/material.dart';
import 'occurrence_data_page.dart';
import 'services/case_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repository = CaseRepository();
  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    final cases = await _repository.getCases();
    if (mounted) {
      setState(() {
        _cases = cases.reversed.toList(); // Show newest first
        _isLoading = false;
      });
    }
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
              'Meus Casos',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Text(
              'Perícias em andamento',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Color(0xFF1F2937),
            child: Icon(Icons.person, color: Color(0xFF06B6D4)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
          : _cases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open,
                          size: 64,
                          color: const Color(0xFF9CA3AF).withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum caso iniciado',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cases.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final caso = _cases[index];
                        return _buildCaseCard(context, caso);
                      },
                    ),
                    Positioned(
                      bottom: 24,
                      left: 24,
                      child: const Text(
                        'Armazenamento Local',
                        style:
                            TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(builder: (context) => const OccurrenceDataPage()),
          )
              .then((_) {
            _loadCases(); // Reload when coming back
          });
        },
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, Map<String, dynamic> caso) {
    IconData icon;
    String type = caso['type'] ?? 'Desconhecido';
    if (type.contains('Celular') ||
        type.contains('iPhone') ||
        type.contains('Samsung')) {
      icon = Icons.smartphone;
    } else if (type.contains('Notebook') || type.contains('Computador')) {
      icon = Icons.computer;
    } else {
      icon = Icons.storage;
    }

    Color statusColor;
    String statusText;
    Color statusBg;

    switch (caso['status']) {
      case 'ready':
        statusColor = const Color(0xFF10B981); // emerald-500
        statusBg = const Color(0xFF064E3B); // emerald-900
        statusText = 'Pronto p/ Envio';
        break;
      case 'synced':
        statusColor = const Color(0xFF3B82F6); // blue-500
        statusBg = const Color(0xFF1E3A8A); // blue-900
        statusText = 'Sincronizado';
        break;
      default:
        statusColor = const Color(0xFF9CA3AF); // gray-400
        statusBg = const Color(0xFF374151); // gray-700
        statusText = 'Rascunho';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937), // gray-800
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF374151)), // gray-700
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151), // gray-700
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF22D3EE)), // cyan-400
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caso['bop'] ?? 'Sem BOP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style:
                        const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                  ),
                  Text(
                    caso['crime'] ?? 'Não informado',
                    style:
                        const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (caso['hash'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.lock, size: 12, color: statusColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
