import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
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
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0A0818),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const AnimatedSplash(),
    );
  }
}

// ============================================================
//  ANIMATED SPLASH SCREEN
// ============================================================
class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});
  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ));
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0A0818), Color(0xFF1B1240), Color(0xFF0A0818)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.5),
                            blurRadius: 40, spreadRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 28),
                  const Text("EnhanceAI",
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  const Text("AI Photo Enhancer",
                      style: TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  ENHANCEMENT LOGIC (isolate)
// ============================================================
Uint8List _processImage(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final mode = args['mode'] as String;
  final intensity = (args['intensity'] as num).toDouble();

  var decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Decode failed');
  decoded = img.bakeOrientation(decoded);

  const maxDim = 1600;
  if (decoded.width > maxDim || decoded.height > maxDim) {
    final ratio = maxDim / (decoded.width > decoded.height ? decoded.width : decoded.height);
    decoded = img.copyResize(decoded,
        width: (decoded.width * ratio).round(),
        height: (decoded.height * ratio).round(),
        interpolation: img.Interpolation.average);
  }

  var out = img.copyResize(decoded,
      width: decoded.width * 2,
      height: decoded.height * 2,
      interpolation: img.Interpolation.cubic);

  final t = intensity.clamp(0.0, 1.0);

  double lerp(double a, double b, double k) => a + (b - a) * k;

  switch (mode) {
    case 'portrait':
      out = img.adjustColor(out,
          contrast: lerp(1.0, 1.10, t),
          saturation: lerp(1.0, 1.12, t),
          brightness: lerp(1.0, 1.03, t),
          gamma: lerp(1.0, 0.97, t));
      break;
    case 'landscape':
      out = img.adjustColor(out,
          contrast: lerp(1.0, 1.18, t),
          saturation: lerp(1.0, 1.30, t),
          brightness: lerp(1.0, 1.02, t));
      break;
    case 'old':
      out = img.adjustColor(out,
          contrast: lerp(1.0, 1.30, t),
          saturation: lerp(1.0, 0.85, t),
          brightness: lerp(1.0, 1.05, t),
          gamma: lerp(1.0, 1.05, t));
      out = img.sepia(out, amount: 0.30 * t);
      break;
    case 'vivid':
      out = img.adjustColor(out,
          contrast: lerp(1.0, 1.25, t),
          saturation: lerp(1.0, 1.50, t),
          brightness: lerp(1.0, 1.05, t));
      break;
    case 'soft':
      out = img.adjustColor(out,
          contrast: lerp(1.0, 0.95, t),
          saturation: lerp(1.0, 1.10, t),
          brightness: lerp(1.0, 1.08, t),
          gamma: lerp(1.0, 1.05, t));
      break;
  }

  final jpg = img.encodeJpg(out, quality: 95);
  return Uint8List.fromList(jpg);
}

Future<Uint8List> processImage(Uint8List bytes, String mode, double intensity) {
  return compute(_processImage, {
    'bytes': bytes,
    'mode': mode,
    'intensity': intensity,
  });
}

// ============================================================
//  HOME PAGE
// ============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Uint8List? _originalBytes;
  Uint8List? _enhancedBytes;
  bool _loading = false;
  String? _error;
  String _mode = "portrait";
  double _intensity = 0.7;

  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;

  final List<Map<String, dynamic>> _modes = const [
    {"id": "portrait",  "label": "Portrait",  "icon": Icons.person_outline},
    {"id": "landscape", "label": "Landscape", "icon": Icons.landscape_outlined},
    {"id": "old",       "label": "Old Photo", "icon": Icons.auto_stories_outlined},
    {"id": "vivid",     "label": "Vivid",     "icon": Icons.palette_outlined},
    {"id": "soft",      "label": "Soft",      "icon": Icons.blur_on_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

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
    final start = DateTime.now();
    try {
      final result = await processImage(_originalBytes!, _mode, _intensity);
      // minimum 800ms so the loading animation feels intentional
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      if (elapsed < 800) await Future.delayed(Duration(milliseconds: 800 - elapsed));
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
      _toast("Saved to gallery ✓", success: true);
    } catch (e) {
      if (!mounted) return;
      _toast("Save failed: $e");
    }
  }

  void _toast(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(msg),
    ));
  }

  void _reset() {
    setState(() {
      _originalBytes = null;
      _enhancedBytes = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0A0818), Color(0xFF1B1240), Color(0xFF0A0818)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    children: [
                      _imageArea(),
                      const SizedBox(height: 22),
                      _modeSelector(),
                      const SizedBox(height: 18),
                      _intensitySlider(),
                      const SizedBox(height: 18),
                      _actionButtons(),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.4)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                          ]),
                        ),
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
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(children: [
      AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) {
          final glow = 8 + _pulseCtrl.value * 12;
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.5),
                    blurRadius: glow, spreadRadius: 1),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          );
        },
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("EnhanceAI",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 0.3)),
            Text("AI Photo Enhancer",
                style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1)),
          ],
        ),
      ),
      if (_originalBytes != null)
        IconButton(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          tooltip: "Start over",
        ),
    ]),
  );

  Widget _imageArea() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey('${_originalBytes?.length}-${_enhancedBytes?.length}-$_loading'),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_loading) return _loadingCard();
    if (_originalBytes == null) return _emptyCard();
    if (_enhancedBytes != null) {
      return BeforeAfterSlider(before: _originalBytes!, after: _enhancedBytes!);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.memory(_originalBytes!,
          fit: BoxFit.cover, height: 340, width: double.infinity),
    );
  }

  Widget _emptyCard() {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      child: Stack(children: [
        // Shimmer sweep
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            return Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Transform.translate(
                  offset: Offset(-300 + _shimmerCtrl.value * 700, 0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7C4DFF).withOpacity(0.08 + _pulseCtrl.value * 0.08),
                    border: Border.all(
                      color: const Color(0xFF7C4DFF).withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.add_photo_alternate_outlined,
                      size: 42, color: Colors.white60),
                ),
              ),
              const SizedBox(height: 18),
              const Text("Pick a photo to get started",
                  style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text("Gallery or camera",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.15),
            const Color(0xFF448AFF).withOpacity(0.15),
          ],
        ),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70, height: 70,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 70, height: 70,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7C4DFF)),
                    backgroundColor: Colors.white12,
                  ),
                ),
                const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
              ]),
            ),
            const SizedBox(height: 22),
            const Text("Enhancing…",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text("Applying ${'AI'} magic",
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _modeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 10),
        child: Text("ENHANCE MODE",
            style: TextStyle(color: Colors.white54, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      ),
      SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _modes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
            final m = _modes[i];
            final active = _mode == m["id"];
            return GestureDetector(
              onTap: () => setState(() => _mode = m["id"]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 96,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: active ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? Colors.transparent : Colors.white.withOpacity(0.1),
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.4),
                          blurRadius: 16, offset: const Offset(0, 6))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(m["icon"] as IconData,
                        color: active ? Colors.white : Colors.white60, size: 26),
                    const SizedBox(height: 8),
                    Text(m["label"] as String,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white60,
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _intensitySlider() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("INTENSITY",
                style: TextStyle(color: Colors.white54, fontSize: 11,
                    fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("${(_intensity * 100).round()}%",
                  style: const TextStyle(color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF7C4DFF),
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF7C4DFF).withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          ),
          child: Slider(
            value: _intensity,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => setState(() => _intensity = v),
          ),
        ),
      ],
    ),
  );

  Widget _actionButtons() => Column(
    children: [
      Row(children: [
        Expanded(child: _btn("Gallery", Icons.photo_library_outlined,
            () => _pick(ImageSource.gallery), outlined: true)),
        const SizedBox(width: 10),
        Expanded(child: _btn("Camera", Icons.camera_alt_outlined,
            () => _pick(ImageSource.camera), outlined: true)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          flex: _enhancedBytes != null ? 1 : 2,
          child: _btn(
            _loading ? "Enhancing…" : "Enhance",
            Icons.auto_fix_high,
            _originalBytes == null || _loading ? null : _enhance,
            gradient: true,
            loading: _loading,
          ),
        ),
        if (_enhancedBytes != null) ...[
          const SizedBox(width: 10),
          Expanded(child: _btn("Save", Icons.download_outlined, _save, outlined: true)),
        ],
      ]),
    ],
  );

  Widget _btn(String label, IconData icon, VoidCallback? onTap,
      {bool outlined = false, bool gradient = false, bool loading = false}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onTap == null && !loading ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: gradient
                ? const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: gradient ? null : (outlined ? Colors.transparent : Colors.white.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(16),
            border: outlined ? Border.all(color: Colors.white.withOpacity(0.15), width: 1.2) : null,
            boxShadow: gradient && onTap != null
                ? [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.35),
                    blurRadius: 18, offset: const Offset(0, 6))]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (loading)
              const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
            else
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15,
                  letterSpacing: 0.2,
                )),
          ]),
        ),
      ),
    );
  }
}

// ============================================================
//  BEFORE / AFTER SLIDER
// ============================================================
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
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
                  child: Container(width: 2.5, color: Colors.white)),
              Positioned(
                left: _pos * w - 22,
                top: h / 2 - 22,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4),
                        blurRadius: 12, spreadRadius: 1)],
                  ),
                  child: const Icon(Icons.compare_arrows, size: 22, color: Colors.black87),
                ),
              ),
              Positioned(top: 14, left: 14, child: _badge("BEFORE")),
              Positioned(top: 14, right: 14, child: _badge("AFTER", accent: true)),
            ]),
          ),
        ),
      );
    });
  }

  Widget _badge(String t, {bool accent = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: accent ? const Color(0xFF7C4DFF).withOpacity(0.85) : Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Text(t,
            style: const TextStyle(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.w800, letterSpacing: 1.2,
            )),
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
