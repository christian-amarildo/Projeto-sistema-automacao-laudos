import 'package:flutter/material.dart';

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForensiChain Desktop')),
      body: const Center(
        child: Text('Desktop Interface - Drag & Drop & Validation'),
      ),
    );
  }
}
