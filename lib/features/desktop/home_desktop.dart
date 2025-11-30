import 'package:flutter/material.dart';
import 'dropzone_page.dart';

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForensiChain Desktop')),
      body: const DropzonePage(),
    );
  }
}
