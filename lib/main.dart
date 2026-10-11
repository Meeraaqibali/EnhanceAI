import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

const String kBackendUrl = "http://10.0.2.2:8000";

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const EnhanceApp());
}

class EnhanceApp extends StatelessWidget {
  const EnhanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnhanceAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0B1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
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
  File? _picked;
  Uint8List? _enhanced;
  bool _loading = false;
  String? _error;
  String _mode = "portrait";

  final List<Map<String, String>> _modes = const [
    {"id": "portrait", "label": "Portrait", "icon": "👤"},
    {"id": "landscape", "label": "Landscape", "icon": "🏞"},
    {"id": "old", "label": "Old Photo", "icon": "📷"},
  ];

  Future<void> _pick(ImageSource src) async {
    final picked = await ImagePicker().pickImage(source: src, imageQuality: 95);
    if (picked == null) return;
    setState(() {
      _picked = File(picked.path);
      _enhanced = null;
      _error = null;
    });
  }

  Future<void> _enhance() async {
    if (_picked == null) return;
    setState(() { _loading = true; _error = null; });

    try {
      final uri = Uri.parse("$kBackendUrl/enhance/$_mode");
      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', _picked!.path));

      final res = await http.Response.fromStream(await req.send());
      if (res.statusCode == 200) {
        setState(() => _enhanced = res.bodyBytes);
      } else {
        setState(() => _error = "Server error ${res.statusCode}");
      }
    } catch (e) {
      setState(() => _error = "Connection failed. Is the backend running?");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_enhanced == null) return;
    final tmp = await getTemporaryDirectory();
    final path = "${tmp.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.png";
    await File(path).writeAsBytes(_enhanced!);
    final result = await ImageGallerySaver.saveFile(path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result != null ? "Saved to gallery ✓" : "Save failed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E0B1F), Color(0xFF1B1240), Color(0xFF0E0B1F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _imageArea(),
                  const SizedBox(height: 20),
                  _modeSelector(),
                  const SizedBox(height: 20),
                  _actionButtons(),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                ]),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      const SizedBox(width: 12),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("EnhanceAI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("AI photo enhancer", style: TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    ]),
  );

  Widget _imageArea() {
    if (_picked == null) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 64, color: Colors.white24),
            SizedBox(height: 12),
            Text("Pick an image to start", style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    if (_enhanced != null) {
      return BeforeAfterSlider(before: _picked!, after: _enhanced!);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(_picked!, fit: BoxFit.cover, height: 320, width: double.infinity),
    );
  }

  Widget _modeSelector() => SizedBox(
    height: 52,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _modes.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (ctx, i) {
        final m = _modes[i];
        final active = _mode == m["id"];
        return GestureDetector(
          onTap: () => setState(() => _mode = m["id"]!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: active ? const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)]) : null,
              color: active ? null : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: active ? Colors.transparent : Colors.white.withOpacity(0.1)),
            ),
            child: Row(children: [
              Text(m["icon"]!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(m["label"]!, style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
            ]),
          ),
        );
      },
    ),
  );

  Widget _actionButtons() => Row(children: [
    Expanded(child: _btn("Gallery", Icons.photo_library, () => _pick(ImageSource.gallery), outlined: true)),
    const SizedBox(width: 10),
    Expanded(child: _btn("Camera", Icons.camera_alt, () => _pick(ImageSource.camera), outlined: true)),
  ]);

  Widget _btn(String label, IconData icon, VoidCallback onTap, {bool outlined = false, bool gradient = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient ? const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)]) : null,
          color: gradient ? null : (outlined ? Colors.transparent : Colors.white.withOpacity(0.06)),
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: Colors.white.withOpacity(0.15)) : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class BeforeAfterSlider extends StatefulWidget {
  final File before;
  final Uint8List after;
  const BeforeAfterSlider({super.key, required this.before, required this.after});

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _pos = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final w = box.maxWidth;
      final h = 340.0;
      return Container(
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onHorizontalDragUpdate: (d) => setState(() => _pos = (d.localPosition.dx / w).clamp(0.0, 1.0)),
            child: Stack(children: [
              Positioned.fill(child: Image.memory(widget.after, fit: BoxFit.cover)),
              Positioned.fill(
                child: ClipRect(
                  clipper: _LeftClipper(_pos),
                  child: Image.file(widget.before, fit: BoxFit.cover, width: w, height: h),
                ),
              ),
              Positioned(
                left: _pos * w - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: Colors.white),
              ),
              Positioned(
                left: _pos * w - 18,
                top: h / 2 - 18,
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.compare_arrows, size: 20, color: Colors.black87),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: _badge("BEFORE"),
              ),
              Positioned(
                top: 12, right: 12,
                child: _badge("AFTER"),
              ),
            ]),
          ),
        ),
      );
    });
  }

  Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}

class _LeftClipper extends CustomClipper<Rect> {
  final double pos;
  _LeftClipper(this.pos);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * pos, size.height);
  @override
  bool shouldReclip(_LeftClipper old) => old.pos != pos;
}
