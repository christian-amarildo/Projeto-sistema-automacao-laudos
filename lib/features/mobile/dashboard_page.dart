import 'package:flutter/material.dart';
import 'occurrence_data_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cases = [
      {
        'id': 1,
        'bop': '12345/2025.000001-0',
        'type': 'Celular Samsung',
        'crime': 'Furto',
        'status': 'draft',
      },
      {
        'id': 2,
        'bop': '12346/2025.000002-0',
        'type': 'iPhone 13 Pro',
        'crime': 'Roubo',
        'status': 'ready',
      },
      {
        'id': 3,
        'bop': '12347/2025.000003-0',
        'type': 'Notebook Dell',
        'crime': 'Estelionato',
        'status': 'synced',
      },
    ];

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
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cases.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final caso = cases[index];
              return _buildCaseCard(context, caso);
            },
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: const Text(
              'Última sincronização: Hoje às 14:32',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const OccurrenceDataPage()),
          );
        },
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, Map<String, dynamic> caso) {
    IconData icon;
    String type = caso['type'];
    if (type.contains('Celular') || type.contains('iPhone')) {
      icon = Icons.smartphone;
    } else if (type.contains('Notebook')) {
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
                    caso['bop'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caso['type'],
                    style:
                        const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                  ),
                  Text(
                    caso['crime'],
                    style:
                        const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
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
        ],
      ),
    );
  }
}
