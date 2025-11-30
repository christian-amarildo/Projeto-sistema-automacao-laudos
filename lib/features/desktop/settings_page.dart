import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _pythonPathController = TextEditingController();
  final _scriptPathController = TextEditingController();
  final _outputDirController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pythonPathController.text =
          prefs.getString('python_path') ?? r'C:\Python39\python.exe';
      _scriptPathController.text = prefs.getString('script_path') ?? '';
      _outputDirController.text =
          prefs.getString('output_dir') ?? r'C:\ForensiChain\Laudos';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('python_path', _pythonPathController.text);
    await prefs.setString('script_path', _scriptPathController.text);
    await prefs.setString('output_dir', _outputDirController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _pickFile(TextEditingController controller,
      {List<String>? extensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: extensions != null ? FileType.custom : FileType.any,
      allowedExtensions: extensions,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        controller.text = result.files.single.path!;
      });
    }
  }

  Future<void> _pickDirectory(TextEditingController controller) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        controller.text = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title:
            const Text('Configurações', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingField(
              'Caminho do Python (.exe)',
              _pythonPathController,
              onPick: () =>
                  _pickFile(_pythonPathController, extensions: ['exe']),
            ),
            const SizedBox(height: 24),
            _buildSettingField(
              'Caminho do Script Bridge (bridge.py)',
              _scriptPathController,
              onPick: () =>
                  _pickFile(_scriptPathController, extensions: ['py']),
            ),
            const SizedBox(height: 24),
            _buildSettingField(
              'Diretório de Saída dos Laudos',
              _outputDirController,
              onPick: () => _pickDirectory(_outputDirController),
              isDir: true,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar Configurações',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingField(String label, TextEditingController controller,
      {required VoidCallback onPick, bool isDir = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onPick,
              icon: Icon(isDir ? Icons.folder_open : Icons.file_open,
                  color: const Color(0xFF06B6D4)),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
