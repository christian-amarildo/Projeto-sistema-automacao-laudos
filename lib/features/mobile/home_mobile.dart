import 'package:flutter/material.dart';
import 'collection_page.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForensiChain Mobile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mobile Interface - Camera & OCR'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GuidedCollectionPage(),
                  ),
                );
              },
              child: const Text('Ir para Coleta Guiada'),
            ),
          ],
        ),
      ),
    );
  }
}
