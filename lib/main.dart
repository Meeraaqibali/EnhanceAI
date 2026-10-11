import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// Change this to your backend URL (use your PC/server IP or a hosted URL)
const String kBackendUrl = "http://10.0.2.2:8000/enhance/";

void main() => runApp(const EnhanceApp());

class EnhanceApp extends StatelessWidget {
  const EnhanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnhanceAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _pickedImage;
  Uint8List? _enhancedBytes;
  bool _loading = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _pickedImage = File(picked.path);
      _enhancedBytes = null;
      _error = null;
    });
  }

  Future<void> _enhance() async {
    if (_pickedImage == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(kBackendUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', _pickedImage!.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        setState(() => _enhancedBytes = response.bodyBytes);
      } else {
        setState(() => _error = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _error = "Failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EnhanceAI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_pickedImage != null)
              Image.file(_pickedImage!, height: 240),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text("Pick"),
                ),
                ElevatedButton.icon(
                  onPressed: _pickedImage == null || _loading ? null : _enhance,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text("Enhance"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_enhancedBytes != null) ...[
              const Text("Enhanced:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.memory(_enhancedBytes!, height: 240),
            ],
          ],
        ),
      ),
    );
  }
}
