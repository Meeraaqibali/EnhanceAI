import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';

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

// ---------- Image processing (runs in isolate) ----------
Uint8List _processImage(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final mode = args['mode'] as String;

  var decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Decode failed');
  decoded = img.bakeOrientation(decoded);

  // Downscale first if too large to avoid OOM
  const maxDim = 1600;
  if (decoded.width > maxDim || decoded.height > maxDim) {
    final ratio = maxDim / (decoded.width > decoded.height ? decoded.width : decoded.height);
    decoded = img.copyResize(
      decoded,
      width: (decoded.width * ratio).round(),
      height: (decoded.height * ratio).round(),
      interpolation: img.Interpolation.average,
    );
  }

  // Upscale 2x with high quality
  var out = img.copyResize(
    decoded,
    width: decoded.width * 2,
    height: decoded.height * 2,
    interpolation: img.Interpolation.cubic,
  );

  switch (mode) {
    case 'portrait':
      out = img.adjustColor(
        out,
        contrast: 1.12,
        saturation: 1.15,
        brightness: 1.05,
        gamma: 0.95,
      );
      // Gentle sharpen
      out = img.convolution(out, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0,
      ], div: 1);
      break;

    case 'landscape':
      out = img.adjustColor(
        out,
        contrast: 1.2,
        saturation: 1.35,
        brightness: 1.02,
      );
      out = img.convolution(out, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0,
      ], div: 1);
      break;

    case 'old':
      // Warm, restored look
      out = img.adjustColor(
        out,
        contrast: 1.35,
        saturation: 0.85,
        brightness: 1.05,
        gamma: 1.05,
      );
      out = img.sepia(out, amount: 0.35);
      // Aggressive sharpen to revive details
      out = img.convolution(out, filter: [
        -1, -1, -1,
        -1, 9, -1,
        -1, -1, -1,
      ], div: 1);
      break;
  }

  final jpg = img.encodeJpg(out, quality: 95);
  return Uint8List.fromList(jpg);
}

Future<Uint8List> processImage(Uint8List bytes, String mode) {
  return compute(_processImage, {'bytes': bytes, 'mode': mode});
}

// ---------- UI ----------
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _originalBytes;
  Uint8List? _enhancedBytes;
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
    final bytes = await picked.readAsBytes();
    setState(() {
      _originalBytes = bytes;
      _enhancedBytes = null;
      _error = null;
    });
  }

  Future<void> _enhance() async {
    if (_originalBytes == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await processImage(_originalBytes!, _mode);
      setState(() => _enhancedBytes = result);
    } catch (e) {
      setState(() => _error = "Enhance failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_enhancedBytes == null) return;
    try {
      await Gal.putImageBytes(_enhancedBytes!, album: 'EnhanceAI');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved to gallery ✓")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _imageArea(),
                      const SizedBox(height: 20),
                      _modeSelector(),
                      const SizedBox(height: 20),
                      _actionButtons(),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                      ],
                    ],
                  ),
                ),
              ),
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
          Text("EnhanceAI",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("On-device photo enhancer",
              style: TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    ]),
  );

  Widget _imageArea() {
    if (_originalBytes == null) {
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

    if (_enhancedBytes != null) {
      return BeforeAfterSlider(before: _originalBytes!, after: _enhancedBytes!);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.memory(_originalBytes!, fit: BoxFit.cover, height: 320, width: double.infinity),
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
              gradient: active
                  ? const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)])
                  : null,
              color: active ? null : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? Colors.transparent : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(children: [
              Text(m["icon"]!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(m["label"]!,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white70,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  )),
            ]),
          ),
        );
      },
    ),
  );

  Widget _actionButtons() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _btn("Gallery", Icons.photo_library, () => _pick(ImageSource.gallery))),
          const SizedBox(width: 10),
          Expanded(child: _btn("Camera", Icons.camera_alt, () => _pick(ImageSource.camera))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _btn(
              _loading ? "Enhancing..." : "Enhance",
              Icons.auto_fix_high,
              _originalBytes == null || _loading ? null : _enhance,
              gradient: true,
            ),
          ),
          if (_enhancedBytes != null) ...[
            const SizedBox(width: 10),
            Expanded(child: _btn("Save", Icons.download, _save, outlined: true)),
          ],
        ]),
      ],
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback? onTap,
      {bool outlined = false, bool gradient = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: gradient
                ? const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)])
                : null,
            color: gradient ? null : (outlined ? Colors.transparent : Colors.white.withOpacity(0.06)),
            borderRadius: BorderRadius.circular(14),
            border: outlined ? Border.all(color: Colors.white.withOpacity(0.15)) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (gradient && onTap == null)
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class BeforeAfterSlider extends StatefulWidget {
  final Uint8List before;
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
      const h = 340.0;
      return Container(
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onHorizontalDragUpdate: (d) =>
                setState(() => _pos = (d.localPosition.dx / w).clamp(0.0, 1.0)),
            child: Stack(children: [
              Positioned.fill(child: Image.memory(widget.after, fit: BoxFit.cover)),
              Positioned.fill(
                child: ClipRect(
                  clipper: _LeftClipper(_pos),
                  child: Image.memory(widget.before, fit: BoxFit.cover, width: w, height: h),
                ),
              ),
              Positioned(left: _pos * w - 1, top: 0, bottom: 0,
                  child: Container(width: 2, color: Colors.white)),
              Positioned(
                left: _pos * w - 18,
                top: h / 2 - 18,
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.compare_arrows, size: 20, color: Colors.black87),
                ),
              ),
              Positioned(top: 12, left: 12, child: _badge("BEFORE")),
              Positioned(top: 12, right: 12, child: _badge("AFTER")),
            ]),
          ),
        ),
      );
    });
  }

  Widget _badge(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
