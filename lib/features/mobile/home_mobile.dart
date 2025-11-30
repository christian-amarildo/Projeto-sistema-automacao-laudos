import 'package:flutter/material.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForensiChain Mobile')),
      body: const Center(
        child: Text('Mobile Interface - Camera & OCR'),
      ),
    );
  }
}
