import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';

// ============================================================
//  SETTINGS MODEL
// ============================================================
class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');
  Color _accent = const Color(0xFF7C4DFF);

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  Color get accent => _accent;
  bool get isRtl => ['ur', 'ar'].contains(_locale.languageCode);

  void setTheme(ThemeMode m) { _themeMode = m; notifyListeners(); }
  void setLocale(Locale l) { _locale = l; notifyListeners(); }
  void setAccent(Color c) { _accent = c; notifyListeners(); }
}

final appSettings = AppSettings();

// ============================================================
//  TRANSLATIONS
// ============================================================
class T {
  static const Map<String, Map<String, String>> _data = {
    'en': {
      'tagline': 'AI Photo Enhancer',
      'pickPhoto': 'Pick a photo to get started',
      'tapToPick': 'Tap to pick a photo',
      'galleryCamera': 'Gallery or camera',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'enhance': 'Enhance',
      'enhancing': 'Enhancing...',
      'save': 'Save',
      'portrait': 'Portrait',
      'landscape': 'Landscape',
      'old': 'Old Photo',
      'vivid': 'Vivid',
      'soft': 'Soft',
      'intensity': 'Intensity',
      'enhanceMode': 'Enhance Mode',
      'settings': 'Settings',
      'guide': 'App Guide',
      'theme': 'Theme',
      'language': 'Language',
      'about': 'About',
      'dark': 'Dark',
      'light': 'Light',
      'system': 'System',
      'accent': 'Accent Color',
      'savedGallery': 'Saved to gallery',
      'pickPhotoTitle': 'Pick a photo',
      'startOver': 'Start over',
      'pressBackExit': 'Press back again to exit',
      'howToUse': 'How to Use',
      'guideIntro': 'Follow these steps to enhance your photos.',
      'step1Title': 'Pick a photo',
      'step1Body': 'Tap the empty card or use Gallery / Camera buttons.',
      'step2Title': 'Choose a mode',
      'step2Body': 'Portrait for faces, Landscape for scenery, Old Photo for vintage shots.',
      'step3Title': 'Adjust intensity',
      'step3Body': 'Slide from 0 percent (subtle) to 100 percent (strong).',
      'step4Title': 'Enhance and save',
      'step4Body': 'Tap Enhance, then save your enhanced image to the gallery.',
      'aboutBody': 'A modern on-device photo enhancer built with Flutter. All processing happens locally on your device - no uploads, no servers, completely private.',
      'version': 'Version 1.0.0',
      'before': 'BEFORE',
      'after': 'AFTER',
    },
    'ur': {
      'tagline': 'اے آئی فوٹو بہتر بنانے والا',
      'pickPhoto': 'شروع کرنے کے لیے تصویر منتخب کریں',
      'tapToPick': 'تصویر منتخب کرنے کے لیے تھپتھپائیں',
      'galleryCamera': 'گیلری یا کیمرہ',
      'gallery': 'گیلری',
      'camera': 'کیمرہ',
      'enhance': 'بہتر بنائیں',
      'enhancing': 'بہتر بنایا جا رہا ہے',
      'save': 'محفوظ کریں',
      'portrait': 'پورٹریٹ',
      'landscape': 'لینڈ اسکیپ',
      'old': 'پرانی تصویر',
      'vivid': 'روشن',
      'soft': 'نرم',
      'intensity': 'شدت',
      'enhanceMode': 'بہتر بنانے کا موڈ',
      'settings': 'ترتیبات',
      'guide': 'رہنمائی',
      'theme': 'تھیم',
      'language': 'زبان',
      'about': 'کے بارے میں',
      'dark': 'تاریک',
      'light': 'روشن',
      'system': 'سسٹم',
      'accent': 'رنگ',
      'savedGallery': 'گیلری میں محفوظ ہو گئی',
      'pickPhotoTitle': 'تصویر منتخب کریں',
      'startOver': 'دوبارہ شروع',
      'pressBackExit': 'باہر نکلنے کے لیے دوبارہ دبائیں',
      'howToUse': 'استعمال کا طریقہ',
      'guideIntro': 'تصاویر بہتر بنانے کے لیے یہ مراحل Follow کریں',
      'step1Title': 'تصویر منتخب کریں',
      'step1Body': 'خالی کارڈ پر تھپتھپائیں یا گیلری یا کیمرہ استعمال کریں',
      'step2Title': 'موڈ منتخب کریں',
      'step2Body': 'چہروں کے لیے پورٹریٹ، مناظر کے لیے لینڈ اسکیپ، پرانی تصویر کے لیے اولڈ',
      'step3Title': 'شدت ایڈجسٹ کریں',
      'step3Body': '0 سے 100 فیصد تک سلائیڈ کریں',
      'step4Title': 'بہتر بنائیں اور محفوظ کریں',
      'step4Body': 'بہتر بنائیں دبائیں، پھر گیلری میں محفوظ کریں',
      'aboutBody': 'Flutter سے بنایا گیا ایک جدید فوٹو بہتر بنانے والا ایپ۔ تمام پروسیسنگ آپ کے فون پر ہوتی ہے',
      'version': 'ورژن 1.0.0',
      'before': 'پہلے',
      'after': 'بعد',
    },
    'ar': {
      'tagline': 'محسن الصور بالذكاء الاصطناعي',
      'pickPhoto': 'اختر صورة للبدء',
      'tapToPick': 'اضغط لاختيار صورة',
      'galleryCamera': 'المعرض أو الكاميرا',
      'gallery': 'المعرض',
      'camera': 'الكاميرا',
      'enhance': 'تحسين',
      'enhancing': 'جار التحسين',
      'save': 'حفظ',
      'portrait': 'صورة شخصية',
      'landscape': 'منظر طبيعي',
      'old': 'صورة قديمة',
      'vivid': 'زاهي',
      'soft': 'ناعم',
      'intensity': 'الشدة',
      'enhanceMode': 'وضع التحسين',
      'settings': 'الإعدادات',
      'guide': 'دليل التطبيق',
      'theme': 'المظهر',
      'language': 'اللغة',
      'about': 'حول',
      'dark': 'داكن',
      'light': 'فاتح',
      'system': 'النظام',
      'accent': 'اللون',
      'savedGallery': 'تم الحفظ في المعرض',
      'pickPhotoTitle': 'اختر صورة',
      'startOver': 'ابدأ من جديد',
      'pressBackExit': 'اضغط مرة أخرى للخروج',
      'howToUse': 'كيفية الاستخدام',
      'guideIntro': 'اتبع هذه الخطوات لتحسين صورك',
      'step1Title': 'اختر صورة',
      'step1Body': 'اضغط على البطاقة الفارغة أو استخدم المعرض أو الكاميرا',
      'step2Title': 'اختر الوضع',
      'step2Body': 'صورة شخصية للوجوه، منظر طبيعي للطبيعة، صورة قديمة للصور القديمة',
      'step3Title': 'اضبط الشدة',
      'step3Body': 'اسحب من 0 إلى 100 بالمئة',
      'step4Title': 'حسن واحفظ',
      'step4Body': 'اضغط على تحسين، ثم احفظ الصورة في المعرض',
      'aboutBody': 'محسن صور عصري مبني بـ Flutter. تتم المعالجة محليا على جهازك',
      'version': 'الإصدار 1.0.0',
      'before': 'قبل',
      'after': 'بعد',
    },
  };

  static String t(String key) {
    return _data[appSettings.locale.languageCode]?[key] ??
        _data['en']![key] ??
        key;
  }
}

// ============================================================
//  MAIN
// ============================================================
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const EnhanceApp());
}

class EnhanceApp extends StatelessWidget {
  const EnhanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return MaterialApp(
          title: 'EnhanceAI',
          debugShowCheckedModeBanner: false,
          themeMode: appSettings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: appSettings.accent),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0818),
            colorScheme: ColorScheme.fromSeed(
              seedColor: appSettings.accent,
              brightness: Brightness.dark,
            ),
          ),
          home: const AnimatedSplash(),
        );
      },
    );
  }
}

// ============================================================
//  SPLASH
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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ));
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0818),
              Color.lerp(appSettings.accent, Colors.black, 0.7)!,
              const Color(0xFF0A0818),
            ],
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appSettings.accent, const Color(0xFF448AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                            color: appSettings.accent.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 28),
                  const Text("EnhanceAI",
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(T.t('tagline'),
                      style: const TextStyle(
                          fontSize: 14, color: Colors.white54, letterSpacing: 2)),
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
//  IMAGE PROCESSING
// ============================================================
Uint8List _processImage(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final mode = args['mode'] as String;
  final t = (args['intensity'] as num).toDouble().clamp(0.0, 1.0);

  var src = img.decodeImage(bytes);
  if (src == null) throw Exception('Decode failed');
  src = img.bakeOrientation(src);

  const maxDim = 1600;
  if (src.width > maxDim || src.height > maxDim) {
    final ratio = maxDim / (src.width > src.height ? src.width : src.height);
    src = img.copyResize(src,
        width: (src.width * ratio).round(),
        height: (src.height * ratio).round(),
        interpolation: img.Interpolation.average);
  }

  double c = 1.0, s = 1.0, b = 1.0;
  switch (mode) {
    case 'portrait':
      c = 1.0 + 0.05 * t; s = 1.0 + 0.05 * t; b = 1.0 + 0.02 * t; break;
    case 'landscape':
      c = 1.0 + 0.08 * t; s = 1.0 + 0.10 * t; b = 1.0 + 0.02 * t; break;
    case 'old':
      c = 1.0 + 0.08 * t; s = 1.0 - 0.05 * t; b = 1.0 + 0.03 * t; break;
    case 'vivid':
      c = 1.0 + 0.06 * t; s = 1.0 + 0.14 * t; b = 1.0 + 0.02 * t; break;
    case 'soft':
      c = 1.0 - 0.03 * t; s = 1.0 + 0.03 * t; b = 1.0 + 0.03 * t; break;
  }

  final w = src.width;
  final h = src.height;
  final out = img.Image(width: w, height: h);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      double r = p.r.toDouble() * b;
      double g = p.g.toDouble() * b;
      double bl = p.b.toDouble() * b;

      r = (r - 128.0) * c + 128.0;
      g = (g - 128.0) * c + 128.0;
      bl = (bl - 128.0) * c + 128.0;

      final lum = 0.299 * r + 0.587 * g + 0.114 * bl;
      r = lum + (r - lum) * s;
      g = lum + (g - lum) * s;
      bl = lum + (bl - lum) * s;

      out.setPixelRgb(x, y, r.clamp(0, 255).toInt(),
          g.clamp(0, 255).toInt(), bl.clamp(0, 255).toInt());
    }
  }

  final jpg = img.encodeJpg(out, quality: 95);
  return Uint8List.fromList(jpg);
}

Future<Uint8List> processImage(Uint8List b, String m, double i) {
  return compute(_processImage, {'bytes': b, 'mode': m, 'intensity': i});
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Uint8List? _originalBytes;
  Uint8List? _enhancedBytes;
  bool _loading = false;
  String? _error;
  String _mode = "portrait";
  double _intensity = 0.7;
  DateTime? _lastBackPress;

  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;

  final List<Map<String, dynamic>> _modes = const [
    {"id": "portrait", "labelKey": "portrait", "icon": Icons.person_outline},
    {"id": "landscape", "labelKey": "landscape", "icon": Icons.landscape_outlined},
    {"id": "old", "labelKey": "old", "icon": Icons.auto_stories_outlined},
    {"id": "vivid", "labelKey": "vivid", "icon": Icons.palette_outlined},
    {"id": "soft", "labelKey": "soft", "icon": Icons.blur_on_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    appSettings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    final picked =
        await ImagePicker().pickImage(source: src, imageQuality: 95);
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
    setState(() {
      _loading = true;
      _error = null;
    });
    final start = DateTime.now();
    try {
      final result = await processImage(_originalBytes!, _mode, _intensity);
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      if (elapsed < 800) {
        await Future.delayed(Duration(milliseconds: 800 - elapsed));
      }
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
      _toast(T.t('savedGallery'), success: true);
    } catch (e) {
      if (!mounted) return;
      _toast("Save failed: $e");
    }
  }

  void _toast(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor:
          success ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
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

  Future<bool> _handleBack() async {
    if (_originalBytes != null || _enhancedBytes != null) {
      _reset();
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      _toast(T.t('pressBackExit'));
      return false;
    }
    return true;
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B1240)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(T.t('pickPhotoTitle'),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: AnimatedSheetOption(
                icon: Icons.photo_library_outlined,
                label: T.t('gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.gallery);
                },
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: AnimatedSheetOption(
                icon: Icons.camera_alt_outlined,
                label: T.t('camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.camera);
                },
              )),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _handleBack();
        if (shouldExit && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0A0818),
                      Color.lerp(appSettings.accent, Colors.black, 0.75)!,
                      const Color(0xFF0A0818),
                    ]
                  : [
                      const Color(0xFFF5F3FF),
                      Color.lerp(appSettings.accent, Colors.white, 0.9)!,
                      const Color(0xFFF5F3FF),
                    ],
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
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.4)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13))),
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
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
        child: Row(children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded, size: 26),
          ),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final glow = 8 + _pulseCtrl.value * 12;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [appSettings.accent, const Color(0xFF448AFF)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: appSettings.accent.withOpacity(0.5),
                        blurRadius: glow,
                        spreadRadius: 1),
                  ],
                ),
                child:
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("EnhanceAI",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3)),
                Text(T.t('tagline'),
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        letterSpacing: 1)),
              ],
            ),
          ),
          if (_originalBytes != null)
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded, size: 24),
              tooltip: T.t('startOver'),
            ),
        ]),
      );

  Widget _imageArea() => AnimatedSwitcher(
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
          key: ValueKey(
              '${_originalBytes?.length}-${_enhancedBytes?.length}-$_loading'),
          child: _buildImageContent(),
        ),
      );

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _showPickerSheet,
      child: Container(
        height: 340,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.035)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: appSettings.accent.withOpacity(0.15), width: 1.5),
        ),
        child: Stack(children: [
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) => Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Transform.translate(
                  offset: Offset(-300 + _shimmerCtrl.value * 700, 0),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(isDark ? 0.05 : 0.35),
                          Colors.white.withOpacity(0.0),
                        ])),
                  ),
                ),
              ),
            ),
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
                      color: appSettings.accent
                          .withOpacity(0.08 + _pulseCtrl.value * 0.08),
                      border: Border.all(
                          color: appSettings.accent.withOpacity(0.25),
                          width: 1.5),
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined,
                        size: 42,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(T.t('tapToPick'),
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(T.t('galleryCamera'),
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                        fontSize: 12)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appSettings.accent.withOpacity(0.15),
              const Color(0xFF448AFF).withOpacity(0.15),
            ]),
        border: Border.all(
            color: appSettings.accent.withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(appSettings.accent),
                    backgroundColor: Colors.white12,
                  ),
                ),
                const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
              ]),
            ),
            const SizedBox(height: 22),
            Text(T.t('enhancing'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _modeSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(T.t('enhanceMode').toUpperCase(),
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5)),
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
                return AnimatedModeTile(
                  icon: m["icon"] as IconData,
                  label: T.t(m["labelKey"] as String),
                  active: active,
                  onTap: () => setState(() => _mode = m["id"] as String),
                );
              },
            ),
          ),
        ],
      );

  Widget _intensitySlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(T.t('intensity').toUpperCase(),
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: appSettings.accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10)),
                child: Text("${(_intensity * 100).round()}%",
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: appSettings.accent,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: appSettings.accent.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
                value: _intensity,
                min: 0.0,
                max: 1.0,
                onChanged: (v) => setState(() => _intensity = v)),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    final mode = _modes.firstWhere((m) => m["id"] == _mode);
    final modeName = T.t(mode["labelKey"] as String);
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: AnimatedPressButton(
                  label: T.t('gallery'),
                  icon: Icons.photo_library_outlined,
                  onTap: () => _pick(ImageSource.gallery),
                  outlined: true)),
          const SizedBox(width: 10),
          Expanded(
              child: AnimatedPressButton(
                  label: T.t('camera'),
                  icon: Icons.camera_alt_outlined,
                  onTap: () => _pick(ImageSource.camera),
                  outlined: true)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            flex: _enhancedBytes != null ? 1 : 2,
            child: AnimatedPressButton(
              label: _loading
                  ? T.t('enhancing')
                  : "${T.t('enhance')} $modeName",
              icon: Icons.auto_fix_high,
              onTap:
                  _originalBytes == null || _loading ? null : _enhance,
              gradient: true,
              loading: _loading,
            ),
          ),
          if (_enhancedBytes != null) ...[
            const SizedBox(width: 10),
            Expanded(
                child: AnimatedPressButton(
                    label: T.t('save'),
                    icon: Icons.download_outlined,
                    onTap: _save,
                    outlined: true)),
          ],
        ]),
      ],
    );
  }
}

// ============================================================
//  DRAWER
// ============================================================
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor:
          isDark ? const Color(0xFF14102E) : const Color(0xFFF5F3FF),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      appSettings.accent,
                      const Color(0xFF448AFF),
                    ]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("EnhanceAI",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    Text(T.t('tagline'),
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5))),
                  ],
                ),
              ]),
            ),
            Divider(color: Colors.grey.withOpacity(0.15), height: 1),
            const SizedBox(height: 8),
            _item(context, Icons.menu_book_outlined, T.t('guide'),
                () => _push(context, const GuideScreen())),
            _item(context, Icons.palette_outlined, T.t('theme'),
                () => _sheetTheme(context)),
            _item(context, Icons.language_outlined, T.t('language'),
                () => _sheetLanguage(context)),
            _item(context, Icons.color_lens_outlined, T.t('accent'),
                () => _sheetAccent(context)),
            _item(context, Icons.info_outline, T.t('about'),
                () => _push(context, const AboutScreen())),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(T.t('version'),
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(children: [
              Icon(icon, size: 22),
              const SizedBox(width: 16),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim, child: child),
          ),
        ));
  }

  void _sheetTheme(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheetWrap(context, T.t('theme'), [
        _sheetTile(
          context,
          icon: Icons.dark_mode_outlined,
          label: T.t('dark'),
          selected: appSettings.themeMode == ThemeMode.dark,
          onTap: () {
            appSettings.setTheme(ThemeMode.dark);
            Navigator.pop(context);
          },
        ),
        _sheetTile(
          context,
          icon: Icons.light_mode_outlined,
          label: T.t('light'),
          selected: appSettings.themeMode == ThemeMode.light,
          onTap: () {
            appSettings.setTheme(ThemeMode.light);
            Navigator.pop(context);
          },
        ),
        _sheetTile(
          context,
          icon: Icons.brightness_auto_outlined,
          label: T.t('system'),
          selected: appSettings.themeMode == ThemeMode.system,
          onTap: () {
            appSettings.setTheme(ThemeMode.system);
            Navigator.pop(context);
          },
        ),
      ]),
    );
  }

  void _sheetLanguage(BuildContext context) {
    Navigator.pop(context);
    final langs = [
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'code': 'ur', 'label': 'اردو', 'flag': '🇵🇰'},
      {'code': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheetWrap(
        context,
        T.t('language'),
        langs
            .map((l) => _sheetTile(
                  context,
                  icon: null,
                  emoji: l['flag']!,
                  label: l['label']!,
                  selected: appSettings.locale.languageCode == l['code'],
                  onTap: () {
                    appSettings.setLocale(Locale(l['code']!));
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _sheetAccent(BuildContext context) {
    Navigator.pop(context);
    final colors = [
      const Color(0xFF7C4DFF),
      const Color(0xFF00BFA5),
      const Color(0xFFFF6F00),
      const Color(0xFFE91E63),
      const Color(0xFF448AFF),
      const Color(0xFF43A047),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B1240)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(T.t('accent'),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: colors.map((c) {
              final active = appSettings.accent.value == c.value;
              return GestureDetector(
                onTap: () {
                  appSettings.setAccent(c);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: active ? Colors.white : Colors.transparent,
                        width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: c.withOpacity(active ? 0.6 : 0.3),
                          blurRadius: active ? 20 : 10,
                          spreadRadius: active ? 2 : 0),
                    ],
                  ),
                  child: active
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _sheetWrap(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B1240)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _sheetTile(BuildContext context,
      {IconData? icon,
      String? emoji,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? appSettings.accent.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected
                      ? appSettings.accent.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.15)),
            ),
            child: Row(children: [
              if (emoji != null)
                Text(emoji, style: const TextStyle(fontSize: 22))
              else if (icon != null)
                Icon(icon, size: 22),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500))),
              if (selected)
                Icon(Icons.check_circle,
                    color: appSettings.accent, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  GUIDE SCREEN
// ============================================================
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'icon': Icons.add_photo_alternate_outlined, 't': T.t('step1Title'), 'b': T.t('step1Body')},
      {'icon': Icons.tune_outlined, 't': T.t('step2Title'), 'b': T.t('step2Body')},
      {'icon': Icons.speed_outlined, 't': T.t('step3Title'), 'b': T.t('step3Body')},
      {'icon': Icons.save_alt_outlined, 't': T.t('step4Title'), 'b': T.t('step4Body')},
    ];
    return Scaffold(
      appBar: AppBar(title: Text(T.t('howToUse'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(T.t('guideIntro'),
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7))),
          const SizedBox(height: 24),
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            appSettings.accent,
                            const Color(0xFF448AFF)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(s['icon'] as IconData,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child:
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("${i + 1}. ${s['t']}",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(s['b'] as String,
                            style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.65),
                                height: 1.4)),
                      ])),
                    ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
//  ABOUT SCREEN
// ============================================================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(T.t('about'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [appSettings.accent, const Color(0xFF448AFF)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: appSettings.accent.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 2),
              ],
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 20),
          const Text("EnhanceAI",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(T.t('version'),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Text(T.t('aboutBody'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.75))),
          ),
        ]),
      ),
    );
  }
}

// ============================================================
//  ANIMATED PRESS BUTTON
// ============================================================
class AnimatedPressButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool outlined;
  final bool gradient;
  final bool loading;

  const AnimatedPressButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
    this.gradient = false,
    this.loading = false,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onTap != null || widget.loading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTapDown: (_) => _enabled ? _ctrl.forward() : null,
        onTapUp: (_) => _enabled ? _ctrl.reverse() : null,
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 54,
            decoration: BoxDecoration(
              gradient: widget.gradient
                  ? LinearGradient(
                      colors: [appSettings.accent, const Color(0xFF448AFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.gradient
                  ? null
                  : (widget.outlined
                      ? Colors.transparent
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.7))),
              borderRadius: BorderRadius.circular(16),
              border: widget.outlined
                  ? Border.all(
                      color: appSettings.accent.withOpacity(0.4), width: 1.2)
                  : null,
              boxShadow: widget.gradient && _enabled
                  ? [
                      BoxShadow(
                        color: appSettings.accent
                            .withOpacity(_ctrl.value > 0 ? 0.55 : 0.35),
                        blurRadius: _ctrl.value > 0 ? 26 : 18,
                        offset: const Offset(0, 6),
                        spreadRadius: _ctrl.value > 0 ? 1 : 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white))
                else
                  Icon(widget.icon,
                      color: widget.outlined && !isDark
                          ? Colors.black87
                          : Colors.white,
                      size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.outlined && !isDark
                          ? Colors.black87
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  ANIMATED SHEET OPTION
// ============================================================
class AnimatedSheetOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const AnimatedSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<AnimatedSheetOption> createState() => _AnimatedSheetOptionState();
}

class _AnimatedSheetOptionState extends State<AnimatedSheetOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [appSettings.accent, const Color(0xFF448AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: appSettings.accent.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  ANIMATED MODE TILE
// ============================================================
class AnimatedModeTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AnimatedModeTile({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<AnimatedModeTile> createState() => _AnimatedModeTileState();
}

class _AnimatedModeTileState extends State<AnimatedModeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 96,
          decoration: BoxDecoration(
            gradient: widget.active
                ? LinearGradient(
                    colors: [appSettings.accent, const Color(0xFF448AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            color: widget.active
                ? null
                : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.active
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.2)),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                        color: appSettings.accent.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: widget.active
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                  size: 26),
              const SizedBox(height: 8),
              Text(widget.label,
                  style: TextStyle(
                    color: widget.active
                        ? Colors.white
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                    fontSize: 12,
                    fontWeight:
                        widget.active ? FontWeight.w700 : FontWeight.w500,
                  )),
            ],
          ),
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
  const BeforeAfterSlider(
      {super.key, required this.before, required this.after});
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
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: GestureDetector(
            onHorizontalDragUpdate: (d) => setState(
                () => _pos = (d.localPosition.dx / w).clamp(0.0, 1.0)),
            child: Stack(children: [
              Positioned.fill(
                  child: Image.memory(widget.after, fit: BoxFit.cover)),
              Positioned.fill(
                child: ClipRect(
                  clipper: _LeftClipper(_pos),
                  child: Image.memory(widget.before,
                      fit: BoxFit.cover, width: w, height: h),
                ),
              ),
              Positioned(
                  left: _pos * w - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2.5, color: Colors.white)),
              Positioned(
                left: _pos * w - 22,
                top: h / 2 - 22,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1),
                    ],
                  ),
                  child: const Icon(Icons.compare_arrows,
                      size: 22, color: Colors.black87),
                ),
              ),
              Positioned(top: 14, left: 14, child: _badge(T.t('before'))),
              Positioned(
                  top: 14, right: 14, child: _badge(T.t('after'), accent: true)),
            ]),
          ),
        ),
      );
    });
  }

  Widget _badge(String t, {bool accent = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: accent
              ? appSettings.accent.withOpacity(0.85)
              : Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
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
