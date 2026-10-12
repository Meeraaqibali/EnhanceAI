// LIVE_PREVIEW_V2_BUILD
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'ai_features.dart';

// ============================================================
//  SETTINGS
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

class BackendConfig extends ChangeNotifier {
  String _url = '';
  bool _cloudEnabled = false;
  String get url => _url;
  bool get cloudEnabled => _cloudEnabled && _url.isNotEmpty;
  void setUrl(String v) { _url = v.trim(); notifyListeners(); }
  void setCloudEnabled(bool v) { _cloudEnabled = v; notifyListeners(); }
}
final backendConfig = BackendConfig();

// ============================================================
//  TRANSLATIONS (compact)
// ============================================================
String tr(String key) {
  final lang = appSettings.locale.languageCode;
  final map = _tr[lang] ?? _tr['en']!;
  return map[key] ?? _tr['en']![key] ?? key;
}
const Map<String, Map<String, String>> _tr = {
  'en': {
    'tagline': 'AI Photo Enhancer',
    'tapToPick': 'Tap to pick a photo',
    'gallery': 'Gallery', 'camera': 'Camera',
    'enhance': 'Enhance', 'enhancing': 'Enhancing…', 'save': 'Save',
    'portrait': 'Portrait', 'landscape': 'Landscape', 'old': 'Old Photo',
    'vivid': 'Vivid', 'soft': 'Soft',
    'intensity': 'Intensity', 'enhanceMode': 'Enhance Mode',
    'settings': 'Settings', 'guide': 'App Guide', 'theme': 'Theme',
    'language': 'Language', 'about': 'About',
    'dark': 'Dark', 'light': 'Light', 'system': 'System',
    'accent': 'Accent Color', 'savedGallery': 'Saved to gallery',
    'pickPhotoTitle': 'Pick a photo', 'startOver': 'Start over',
    'pressBackExit': 'Press back again to exit',
    'howToUse': 'How to Use', 'version': 'Version 1.0.0',
    'before': 'BEFORE', 'after': 'AFTER',
    'lens': 'Camera Lens', 'none': 'None',
    'adjust': 'Adjust', 'transform': 'Transform',
    'brightness': 'Brightness', 'contrast': 'Contrast',
    'saturation': 'Saturation', 'warmth': 'Warmth',
    'vignette': 'Vignette', 'sharpness': 'Sharpness',
    'highlights': 'Highlights', 'shadows': 'Shadows',
    'flipH': 'Flip H', 'flipV': 'Flip V', 'rotate': 'Rotate',
    'reset': 'Reset', 'aiFeatures': 'AI Features',
    'bgBlur': 'Background Blur', 'expand': 'Expand Frame',
    'cloudAI': 'Cloud AI', 'backendUrl': 'Backend URL',
    'mode_preset': 'Preset values',
    'guideIntro': 'Follow these steps to enhance your photos.',
    'step1Title': 'Pick a photo',
    'step1Body': 'Tap the card or use Gallery / Camera.',
    'step2Title': 'Choose a mode',
    'step2Body': 'Each mode has its own auto preset.',
    'step3Title': 'Fine-tune',
    'step3Body': 'Adjust sliders, pick a lens, flip or rotate.',
    'step4Title': 'Enhance and save',
    'step4Body': 'Tap Enhance, then save to gallery.',
    'aboutBody':
      'A modern on-device photo enhancer built with Flutter. All processing happens locally — no uploads, no servers, private.',
  },
  'ur': {
    'tagline': 'اے آئی فوٹو بہتر بنانے والا',
    'tapToPick': 'تصویر منتخب کرنے کے لیے تھپتھپائیں',
    'gallery': 'گیلری', 'camera': 'کیمرہ',
    'enhance': 'بہتر بنائیں', 'enhancing': 'ہو رہا ہے', 'save': 'محفوظ',
    'portrait': 'پورٹریٹ', 'landscape': 'لینڈ اسکیپ', 'old': 'پرانی',
    'vivid': 'روشن', 'soft': 'نرم',
    'intensity': 'شدت', 'enhanceMode': 'موڈ',
    'settings': 'ترتیبات', 'guide': 'رہنمائی', 'theme': 'تھیم',
    'language': 'زبان', 'about': 'کے بارے میں',
    'dark': 'تاریک', 'light': 'روشن', 'system': 'سسٹم',
    'accent': 'رنگ', 'savedGallery': 'گیلری میں محفوظ',
    'pickPhotoTitle': 'تصویر منتخب کریں', 'startOver': 'دوبارہ شروع',
    'pressBackExit': 'باہر نکلنے کے لیے دوبارہ دبائیں',
    'howToUse': 'استعمال کا طریقہ', 'version': 'ورژن 1.0.0',
    'before': 'پہلے', 'after': 'بعد',
    'lens': 'کیمرہ لینس', 'none': 'کوئی نہیں',
    'adjust': 'ایڈجسٹ', 'transform': 'تبدیلی',
    'brightness': 'روشنی', 'contrast': 'کنٹراسٹ',
    'saturation': 'سیچوریشن', 'warmth': 'گرمی',
    'vignette': 'وگنیٹ', 'sharpness': 'تیز',
    'highlights': 'ہائی لائٹ', 'shadows': 'شیڈو',
    'flipH': 'افقی', 'flipV': 'عمودی', 'rotate': 'گھمائیں',
    'reset': 'ری سیٹ', 'aiFeatures': 'اے آئی',
    'bgBlur': 'پس منظر دھندلا', 'expand': 'فریم پھیلائیں',
    'cloudAI': 'کلاؤڈ اے آئی', 'backendUrl': 'بیک اینڈ',
    'mode_preset': 'پریسیٹ',
    'guideIntro': 'تصاویر بہتر بنانے کے لیے مراحل',
    'step1Title': 'تصویر', 'step1Body': 'کارڈ پر تھپتھپائیں',
    'step2Title': 'موڈ', 'step2Body': 'ہر موڈ کا اپنا پریسیٹ ہے',
    'step3Title': 'ترتیب', 'step3Body': 'سلائیڈر استعمال کریں',
    'step4Title': 'محفوظ', 'step4Body': 'بہتر بنائیں، پھر محفوظ کریں',
    'aboutBody': 'Flutter سے بنایا گیا۔ تمام پروسیسنگ فون پر',
  },
  'ar': {
    'tagline': 'محسن الصور',
    'tapToPick': 'اضغط لاختيار صورة',
    'gallery': 'المعرض', 'camera': 'الكاميرا',
    'enhance': 'تحسين', 'enhancing': 'جار التحسين', 'save': 'حفظ',
    'portrait': 'شخصية', 'landscape': 'منظر', 'old': 'قديمة',
    'vivid': 'زاهي', 'soft': 'ناعم',
    'intensity': 'الشدة', 'enhanceMode': 'الوضع',
    'settings': 'الإعدادات', 'guide': 'الدليل', 'theme': 'المظهر',
    'language': 'اللغة', 'about': 'حول',
    'dark': 'داكن', 'light': 'فاتح', 'system': 'النظام',
    'accent': 'اللون', 'savedGallery': 'تم الحفظ',
    'pickPhotoTitle': 'اختر صورة', 'startOver': 'ابدأ من جديد',
    'pressBackExit': 'اضغط مرة أخرى للخروج',
    'howToUse': 'كيفية الاستخدام', 'version': 'الإصدار 1.0.0',
    'before': 'قبل', 'after': 'بعد',
    'lens': 'عدسة', 'none': 'بدون',
    'adjust': 'تعديل', 'transform': 'تحويل',
    'brightness': 'سطوع', 'contrast': 'تباين',
    'saturation': 'تشبع', 'warmth': 'دفء',
    'vignette': 'فينييت', 'sharpness': 'حدة',
    'highlights': 'إبرازات', 'shadows': 'ظلال',
    'flipH': 'قلب أفقي', 'flipV': 'قلب عمودي', 'rotate': 'تدوير',
    'reset': 'إعادة', 'aiFeatures': 'ذكاء اصطناعي',
    'bgBlur': 'ضبابية الخلفية', 'expand': 'توسيع الإطار',
    'cloudAI': 'سحابي', 'backendUrl': 'الخادم',
    'mode_preset': 'إعداد مسبق',
    'guideIntro': 'اتبع الخطوات لتحسين صورك',
    'step1Title': 'اختر صورة', 'step1Body': 'اضغط البطاقة',
    'step2Title': 'اختر الوضع', 'step2Body': 'لكل وضع إعداد',
    'step3Title': 'اضبط', 'step3Body': 'استخدم الشرائط',
    'step4Title': 'احفظ', 'step4Body': 'حسن ثم احفظ',
    'aboutBody': 'مبني بـ Flutter. تتم المعالجة محليا',
  },
};

// ============================================================
//  LENS PRESETS  (camera signature simulation)
// ============================================================
class LensPreset {
  final String id, name, brand, emoji;
  final double warmth;      // -1..1
  final double saturation;  // 0.7..1.6
  final double contrast;    // 0.85..1.35
  final double vignette;    // 0..0.7
  final double fade;        // 0..0.3
  final double sharpness;   // 0..1
  const LensPreset({
    required this.id, required this.name, required this.brand,
    required this.emoji, this.warmth = 0, this.saturation = 1.0,
    this.contrast = 1.0, this.vignette = 0, this.fade = 0,
    this.sharpness = 0,
  });
}

const List<LensPreset> kLenses = [
  LensPreset(id: 'none', name: 'None', brand: 'Original', emoji: '🚫'),
  LensPreset(id: 'iphone', name: 'iPhone', brand: 'Apple',
      emoji: '🍎', warmth: 0.10, saturation: 1.08, contrast: 1.05, sharpness: 0.15),
  LensPreset(id: 'samsung', name: 'Galaxy', brand: 'Samsung',
      emoji: '📱', warmth: 0.05, saturation: 1.20, contrast: 1.10, sharpness: 0.20),
  LensPreset(id: 'pixel', name: 'Pixel', brand: 'Google',
      emoji: '🔵', warmth: 0.02, saturation: 1.05, contrast: 1.15, sharpness: 0.10),
  LensPreset(id: 'canon', name: 'EOS 5D', brand: 'Canon',
      emoji: '📷', warmth: 0.15, saturation: 1.10, contrast: 1.02,
      vignette: 0.10, sharpness: 0.12),
  LensPreset(id: 'nikon', name: 'D850', brand: 'Nikon',
      emoji: '📸', warmth: -0.08, saturation: 1.05, contrast: 1.18,
      vignette: 0.15, sharpness: 0.20),
  LensPreset(id: 'sony', name: 'Alpha A7', brand: 'Sony',
      emoji: '🎥', warmth: -0.05, saturation: 1.08, contrast: 1.12,
      sharpness: 0.25),
  LensPreset(id: 'fuji', name: 'X-T5', brand: 'Fujifilm',
      emoji: '🎞', warmth: 0.12, saturation: 0.88, contrast: 0.95,
      fade: 0.15, sharpness: 0.05),
  LensPreset(id: 'leica', name: 'M11', brand: 'Leica',
      emoji: '⭐', warmth: 0.08, saturation: 1.05, contrast: 1.20,
      vignette: 0.20, sharpness: 0.15),
  LensPreset(id: 'film', name: 'Vintage 35mm', brand: 'Film',
      emoji: '🎞', warmth: 0.20, saturation: 0.82, contrast: 0.92,
      fade: 0.25, vignette: 0.25),
  LensPreset(id: 'kodak', name: 'Portra 400', brand: 'Kodak',
      emoji: '🎞', warmth: 0.25, saturation: 0.95, contrast: 0.98,
      fade: 0.10, vignette: 0.10),
  LensPreset(id: 'action', name: 'GoPro', brand: 'Action',
      emoji: '🏄', warmth: -0.05, saturation: 1.25, contrast: 1.15,
      vignette: 0.30, sharpness: 0.30),
];

LensPreset get activeLens => kLenses.firstWhere(
    (l) => l.id == _lensId, orElse: () => kLenses.first);
String _lensId = 'none';
void setLens(String id) { _lensId = id; }

// ============================================================
//  MANUAL ADJUSTMENTS
// ============================================================
class ManualAdjust {
  double brightness = 0;   // -1..1
  double contrast = 0;     // -1..1
  double saturation = 0;   // -1..1
  double warmth = 0;       // -1..1
  double vignette = 0;     // 0..1
  double sharpness = 0;    // 0..1
  double highlights = 0;   // -1..1
  double shadows = 0;      // -1..1
  double rotation = 0;     // 0..360
  bool flipH = false;
  bool flipV = false;
  double clarity = 0;      // 0..1 — mid-tone local contrast

  ManualAdjust clone() => ManualAdjust()
    ..brightness = brightness
    ..contrast = contrast
    ..saturation = saturation
    ..warmth = warmth
    ..vignette = vignette
    ..sharpness = sharpness
    ..highlights = highlights
    ..shadows = shadows
    ..rotation = rotation
    ..flipH = flipH
    ..flipV = flipV
    ..clarity = clarity;

  bool get isDefault =>
      brightness == 0 && contrast == 0 && saturation == 0 && warmth == 0 &&
      vignette == 0 && sharpness == 0 && highlights == 0 && shadows == 0 &&
      rotation == 0 && !flipH && !flipV && clarity == 0;

  Map<String, dynamic> toMap() => {
    'brightness': brightness, 'contrast': contrast,
    'saturation': saturation, 'warmth': warmth,
    'vignette': vignette, 'sharpness': sharpness,
    'highlights': highlights, 'shadows': shadows,
    'rotation': rotation, 'flipH': flipH, 'flipV': flipV,
    'clarity': clarity,
  };
}

// Mode-specific default presets
ManualAdjust presetForMode(String mode) {
  final m = ManualAdjust();
  switch (mode) {
    // -------- PORTRAIT --------
    // Grounded in Nikon Portrait Picture Control (lower clarity, softened skin,
    // lifted shadows) + backlit-portrait workflow values.
    case 'portrait':
      m.saturation = 0.20;
      m.contrast = 0.10;
      m.brightness = 0.10;
      m.highlights = -0.30;
      m.shadows = 0.35;
      m.warmth = 0.12;
      m.clarity = 0.10;
      break;

    // -------- LANDSCAPE --------
    // Grounded in Sony Landscape mode (enhanced contrast + saturation) and
    // Darkroom guidance that clarity is additive and "a little goes a long way".
    case 'landscape':
      m.saturation = 0.42;
      m.contrast = 0.28;
      m.brightness = 0.02;
      m.highlights = -0.20;
      m.shadows = 0.22;
      m.sharpness = 0.22;
      m.clarity = 0.38;
      break;

    // -------- OLD PHOTO (restore, not vintage) --------
    // Grounded in recovery workflow: Highlights -40 to recover blown areas,
    // Shadows +40 to recover dark detail, moderate saturation.
    case 'old':
      m.saturation = 0.18;
      m.contrast = 0.32;
      m.brightness = 0.10;
      m.highlights = -0.40;
      m.shadows = 0.42;
      m.warmth = 0.08;
      m.sharpness = 0.28;
      m.clarity = 0.40;
      break;

    // -------- VIVID --------
    // Grounded in Nikon Vivid Picture Control (Clarity +2, Saturation +0.5,
    // exposure compensation -0.3 to protect highlights).
    case 'vivid':
      m.saturation = 0.55;
      m.contrast = 0.32;
      m.brightness = 0.04;
      m.highlights = -0.18;
      m.shadows = 0.15;
      m.warmth = 0.10;
      m.sharpness = 0.22;
      m.clarity = 0.28;
      break;

    // -------- SOFT / DREAMY --------
    // Grounded in dreamy-look definition: soft light, lifted blacks (low
    // contrast), muted warm palette, lowered clarity.
    case 'soft':
      m.saturation = 0.05;
      m.contrast = -0.22;
      m.brightness = 0.16;
      m.highlights = 0.10;
      m.shadows = 0.45;
      m.warmth = 0.15;
      m.clarity = 0.05;
      break;
  }
  return m;
}

// ============================================================
//  MAIN
// ============================================================
// ============================================================
//  LIVE PREVIEW HELPERS
// ============================================================
Uint8List _downscaleForPreviewStatic(Uint8List bytes) {
  final src = img.decodeImage(bytes);
  if (src == null) return bytes;
  const maxDim = 220;
  final longest = src.width > src.height ? src.width : src.height;
  if (longest <= maxDim) {
    return Uint8List.fromList(img.encodeJpg(src, quality: 85));
  }
  final ratio = maxDim / longest;
  final w = (src.width * ratio).round().clamp(1, maxDim);
  final h = (src.height * ratio).round().clamp(1, maxDim);
  final resized = img.copyResize(src,
      width: w, height: h, interpolation: img.Interpolation.average);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
      builder: (context, _) => MaterialApp(
        title: 'EnhanceAI',
        debugShowCheckedModeBanner: false,
        themeMode: appSettings.themeMode,
        theme: ThemeData(
          useMaterial3: true, brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: appSettings.accent),
        ),
        darkTheme: ThemeData(
          useMaterial3: true, brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0818),
          colorScheme: ColorScheme.fromSeed(
            seedColor: appSettings.accent, brightness: Brightness.dark,
          ),
        ),
        builder: (context, child) {
          final mode = appSettings.themeMode;
          final platformDark =
              MediaQuery.platformBrightnessOf(context) == Brightness.dark;
          final isDark = mode == ThemeMode.dark ||
              (mode == ThemeMode.system && platformDark);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  isDark ? const Color(0xFF0A0818) : const Color(0xFFF5F3FF),
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AnimatedSplash(),
      ),
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
    with TickerProviderStateMixin {
  late AnimationController _inCtrl, _outCtrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _inCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _outCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
        parent: _inCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _inCtrl, curve: const Interval(0.0, 0.5)));
    _inCtrl.forward();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) _outCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 4400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ));
      }
    });
  }

  @override
  void dispose() { _inCtrl.dispose(); _outCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [const Color(0xFF0A0818),
              Color.lerp(appSettings.accent, Colors.black, 0.7)!,
              const Color(0xFF0A0818)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _outCtrl,
            builder: (_, child) => Opacity(
              opacity: (1.0 - _outCtrl.value).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 1.0 + _outCtrl.value * 0.3, child: child),
            ),
            child: AnimatedBuilder(
              animation: _inCtrl,
              builder: (_, __) => FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            appSettings.accent, const Color(0xFF448AFF)]),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [BoxShadow(
                            color: appSettings.accent.withOpacity(0.5),
                            blurRadius: 40, spreadRadius: 4)],
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 60),
                      ),
                      const SizedBox(height: 28),
                      const Text("EnhanceAI", style: TextStyle(
                        fontSize: 34, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(tr('tagline'), style: const TextStyle(
                        fontSize: 14, color: Colors.white54, letterSpacing: 2)),
                    ],
                  ),
                ),
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
  final intensity = (args['intensity'] as num).toDouble();
  final mode = args['mode'] as String;
  final adj = args['adj'] as Map<String, dynamic>;
  final lens = args['lens'] as LensPreset;

  var src = img.decodeImage(bytes);
  if (src == null) throw Exception('decode failed');
  src = img.bakeOrientation(src);

  // Transform
  if (adj['flipH'] as bool) src = img.flipHorizontal(src);
  if (adj['flipV'] as bool) src = img.flipVertical(src);
  final rot = (adj['rotation'] as num).toDouble();
  if (rot != 0) src = img.copyRotate(src, angle: rot);

  const maxDim = 1600;
  if (src.width > maxDim || src.height > maxDim) {
    final ratio = maxDim / (src.width > src.height ? src.width : src.height);
    src = img.copyResize(src,
        width: (src.width * ratio).round(),
        height: (src.height * ratio).round(),
        interpolation: img.Interpolation.average);
  }

  // Combine preset + manual + intensity + lens
  final preset = presetForMode(mode);
  final k = intensity;

  // adj ALREADY contains the mode preset (it is reset to presetForMode()
  // when the user changes mode). Applying 'preset' separately here
  // double-applies every value and overcooks results. Use adj alone.
  double b = (adj['brightness'] as num).toDouble() * k;
  double c = 1.0 + (adj['contrast'] as num).toDouble() * k;
  double s = 1.0 + (adj['saturation'] as num).toDouble() * k;
  double w = (adj['warmth'] as num).toDouble() * k + lens.warmth;
  double vg = (adj['vignette'] as num).toDouble() + lens.vignette;
  double sh = (adj['sharpness'] as num).toDouble() + lens.sharpness;
  double hl = (adj['highlights'] as num).toDouble() * k;
  double sd = (adj['shadows'] as num).toDouble() * k;
  double fade = lens.fade;
  double clarity = ((adj['clarity'] as num?)?.toDouble() ?? 0.0) * k;
  c *= lens.contrast;
  s *= lens.saturation;

  final w0 = src.width, h0 = src.height;
  final out = img.Image(width: w0, height: h0);

  for (int y = 0; y < h0; y++) {
    for (int x = 0; x < w0; x++) {
      final p = src.getPixel(x, y);
      double r = p.r.toDouble();
      double g = p.g.toDouble();
      double bl = p.b.toDouble();

      // brightness
      r += b * 80; g += b * 80; bl += b * 80;

      // highlights / shadows (tone curve)
      final lum = 0.299 * r + 0.587 * g + 0.114 * bl;
      final hiW = (lum / 255).clamp(0.0, 1.0);
      final shW = (1.0 - hiW).clamp(0.0, 1.0);
      r += hl * hiW * 60; g += hl * hiW * 60; bl += hl * hiW * 60;
      r += sd * shW * 60; g += sd * shW * 60; bl += sd * shW * 60;

      // warmth
      r += w * 20; bl -= w * 20;

      // contrast around 128
      r = (r - 128) * c + 128;
      g = (g - 128) * c + 128;
      bl = (bl - 128) * c + 128;

      // saturation
      final l2 = 0.299 * r + 0.587 * g + 0.114 * bl;
      r = l2 + (r - l2) * s;
      g = l2 + (g - l2) * s;
      bl = l2 + (bl - l2) * s;

      // film fade (lifted blacks)
      if (fade > 0) {
        r = r + (255 - r) * fade * 0.15;
        g = g + (255 - g) * fade * 0.15;
        bl = bl + (255 - bl) * fade * 0.15;
        r = r * (1 - fade * 0.1) + 25 * fade;
        g = g * (1 - fade * 0.1) + 20 * fade;
        bl = bl * (1 - fade * 0.1) + 15 * fade;
      }

      out.setPixelRgb(x, y,
          r.clamp(0, 255).toInt(),
          g.clamp(0, 255).toInt(),
          bl.clamp(0, 255).toInt());
    }
  }

  // Clarity — mid-tone local contrast (soft blur + unsharp on mid-freq)
  if (clarity > 0.02) {
    final blurred = img.Image(width: w0, height: h0);
    for (int y = 0; y < h0; y++) {
      for (int x = 0; x < w0; x++) {
        int r = 0, g = 0, b = 0, cnt = 0;
        for (int dy = -1; dy <= 1; dy++) {
          final yy = (y + dy).clamp(0, h0 - 1);
          for (int dx = -1; dx <= 1; dx++) {
            final xx = (x + dx).clamp(0, w0 - 1);
            final p = out.getPixel(xx, yy);
            r += p.r.toInt(); g += p.g.toInt(); b += p.b.toInt();
            cnt++;
          }
        }
        blurred.setPixelRgb(x, y, r ~/ cnt, g ~/ cnt, b ~/ cnt);
      }
    }
    final amt = clarity * 1.15;
    for (int y = 0; y < h0; y++) {
      for (int x = 0; x < w0; x++) {
        final o = out.getPixel(x, y);
        final bl = blurred.getPixel(x, y);
        final nr = o.r + (o.r - bl.r) * amt;
        final ng = o.g + (o.g - bl.g) * amt;
        final nb = o.b + (o.b - bl.b) * amt;
        out.setPixelRgb(x, y,
            nr.clamp(0, 255).toInt(),
            ng.clamp(0, 255).toInt(),
            nb.clamp(0, 255).toInt());
      }
    }
  }

  // Vignette
  if (vg > 0) {
    final cx = w0 / 2, cy = h0 / 2;
    final maxR = math.sqrt(cx * cx + cy * cy);
    for (int y = 0; y < h0; y++) {
      for (int x = 0; x < w0; x++) {
        final dx = x - cx, dy = y - cy;
        final d = math.sqrt(dx * dx + dy * dy) / maxR;
        final f = 1.0 - (vg * d * d);
        final p = out.getPixel(x, y);
        out.setPixelRgb(x, y,
            (p.r * f).clamp(0, 255).toInt(),
            (p.g * f).clamp(0, 255).toInt(),
            (p.b * f).clamp(0, 255).toInt());
      }
    }
  }

  // Sharpness (simple 3x3 unsharp)
  if (sh > 0.02) {
    final amt = sh * 0.8;
    final src2 = out.clone();
    for (int y = 1; y < h0 - 1; y++) {
      for (int x = 1; x < w0 - 1; x++) {
        double r = 0, g = 0, b = 0;
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final px = src2.getPixel(x + dx, y + dy);
            final wgt = (dx == 0 && dy == 0) ? 5.0 : -0.25;
            r += px.r * wgt; g += px.g * wgt; b += px.b * wgt;
          }
        }
        final orig = src2.getPixel(x, y);
        final nr = orig.r * (1 - amt) + r * amt;
        final ng = orig.g * (1 - amt) + g * amt;
        final nb = orig.b * (1 - amt) + b * amt;
        out.setPixelRgb(x, y,
            nr.clamp(0, 255).toInt(),
            ng.clamp(0, 255).toInt(),
            nb.clamp(0, 255).toInt());
      }
    }
  }

  return Uint8List.fromList(img.encodeJpg(out, quality: 95));
}

Future<Uint8List> processImage(
    Uint8List b, String m, double i, ManualAdjust adj, LensPreset lens) {
  return compute(_processImage, {
    'bytes': b, 'mode': m, 'intensity': i,
    'adj': adj.toMap(), 'lens': lens,
  });
}

// ============================================================
//  CLOUD BACKEND CALL
// ============================================================
Future<Uint8List?> enhanceViaBackend(
    Uint8List bytes, String mode, double intensity, {String feature = 'enhance'}) async {
  if (!backendConfig.cloudEnabled) return null;
  try {
    final uri = Uri.parse('${backendConfig.url}/$feature/');
    final req = http.MultipartRequest('POST', uri)
      ..fields['mode'] = mode
      ..fields['intensity'] = intensity.toString()
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'input.jpg'));
    final streamed = await req.send().timeout(const Duration(seconds: 120));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200 && res.bodyBytes.length > 1000) return res.bodyBytes;
    return null;
  } catch (_) { return null; }
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Uint8List? _original, _enhanced;
  bool _loading = false;
  String? _error;
  String _mode = 'portrait';
  double _intensity = 0.7;
  ManualAdjust _adj = presetForMode('portrait');
  DateTime? _lastBack;
  bool _showAdjust = false;
  bool _hasCropped = false;
  double _bgBlurStrength = 0.0;
  bool _faceRestore = false;
  String? _expandRatio;

  // ---- Live preview state ----
  Uint8List? _previewBytes;
  Uint8List? _lowResBytes;
  Timer? _previewTimer;
  bool _renderingPreview = false;
  bool _previewQueued = false;

  late AnimationController _shimmer, _pulse;

  final modes = const [
    {'id': 'portrait',  'k': 'portrait',  'icon': Icons.person_outline},
    {'id': 'landscape', 'k': 'landscape', 'icon': Icons.landscape_outlined},
    {'id': 'old',       'k': 'old',       'icon': Icons.auto_stories_outlined},
    {'id': 'vivid',     'k': 'vivid',     'icon': Icons.palette_outlined},
    {'id': 'soft',      'k': 'soft',      'icon': Icons.blur_on_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    appSettings.addListener(_onChange);
    backendConfig.addListener(_onChange);
  }

  void _onChange() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    appSettings.removeListener(_onChange);
    backendConfig.removeListener(_onChange);
    _previewTimer?.cancel();
    _shimmer.dispose(); _pulse.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource s) async {
    final p = await ImagePicker().pickImage(source: s, imageQuality: 95);
    if (p == null) return;
    final b = await p.readAsBytes();
    setState(() {
      _original = b; _enhanced = null; _error = null;
      _previewBytes = null; _lowResBytes = null;
    });
    try {
      final low = await compute(_downscaleForPreviewStatic, b);
      if (mounted) _lowResBytes = low;
    } catch (_) {}
  }

  Future<void> _enhance() async {
    if (_original == null) return;
    setState(() { _loading = true; _error = null; });
    final t0 = DateTime.now();
    Uint8List? result;

    // 1. Try cloud AI first
    if (backendConfig.cloudEnabled) {
      result = await enhanceViaBackend(_original!, _mode, _intensity);
    }

    // 2. Try on-device AI (face blur / face restore / expand)
    if (result == null) {
      try {
        if (_expandRatio != null) {
          result = await _runExpand(_original!, _expandRatio!);
        } else if (_faceRestore) {
          result = await _runFaceRestore(_original!);
        } else if (_bgBlurStrength > 0.05) {
          result = await _runFaceBlur(_original!);
        } else {
          result = await processImage(_original!, _mode, _intensity, _adj, activeLens);
        }
      } catch (e) {
        setState(() { _error = 'Enhance failed: $e'; _loading = false; });
        return;
      }
    }
    final el = DateTime.now().difference(t0).inMilliseconds;
    if (el < 1200) await Future.delayed(Duration(milliseconds: 1200 - el));
    setState(() { _enhanced = result; _loading = false; });
  }

  Future<void> _save() async {
    if (_enhanced == null) return;
    try {
      await Gal.putImageBytes(_enhanced!, album: 'EnhanceAI');
      if (mounted) _toast(tr('savedGallery'), ok: true);
    } catch (e) { if (mounted) _toast('Save failed: $e'); }
  }

  void _toast(String m, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Text(m),
    ));
  }

  void _reset() { setState(() { _original = null; _enhanced = null; _error = null; }); }


  Future<Uint8List> _runFaceBlur(Uint8List bytes) async {
    return applyFaceBlur(bytes, _bgBlurStrength);
  }

  Future<Uint8List> _runFaceRestore(Uint8List bytes) async {
    return faceAwareRestore(bytes, 1.0);
  }

  Future<Uint8List> _runExpand(Uint8List bytes, String ratio) async {
    int w, h;
    switch (ratio) {
      case '16:9': w = 1600; h = 900; break;
      case '9:16': w = 900; h = 1600; break;
      case '1:1':  w = 1200; h = 1200; break;
      case '4:5':  w = 1000; h = 1250; break;
      default:     w = 1600; h = 900;
    }
    return expandCanvas(bytes, w, h);
  }

  // ---- Live preview pipeline ----
  void _schedulePreview() {
    if (_original == null) return;
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 80), () async {
      if (_lowResBytes == null) {
        try {
          _lowResBytes =
              await compute(_downscaleForPreviewStatic, _original!);
        } catch (_) { return; }
      }
      await _refreshPreview();
    });
  }

  Future<void> _refreshPreview() async {
    if (_lowResBytes == null) return;
    if (_renderingPreview) { _previewQueued = true; return; }
    _renderingPreview = true;
    try {
      Uint8List out;
      if (_expandRatio != null) {
        out = await _runExpand(_lowResBytes!, _expandRatio!);
      } else if (_faceRestore) {
        out = await _runFaceRestore(_lowResBytes!);
      } else if (_bgBlurStrength > 0.05) {
        out = await _runFaceBlur(_lowResBytes!);
      } else {
        out = _processImage({
          'bytes': _lowResBytes!,
          'mode': _mode,
          'intensity': _intensity,
          'adj': _adj.toMap(),
          'lens': activeLens,
        });
      }
      if (mounted) setState(() => _previewBytes = out);
    } catch (_) {}
    _renderingPreview = false;
    if (_previewQueued) { _previewQueued = false; _schedulePreview(); }
  }

  Future<bool> _handleBack() async {
    // Photo is loaded — confirm before discarding
    if (_original != null || _enhanced != null) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B1240) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
          title: const Text('Discard this photo?',
            style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text(
            _enhanced != null
              ? 'Your enhanced photo hasn\'t been saved. It will be lost.'
              : 'Your current edit will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep editing')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent),
              child: const Text('Discard')),
          ],
        ),
      );
      if (discard == true) _reset();
      return false;
    }
    // No photo loaded — double-tap to exit app
    final now = DateTime.now();
    if (_lastBack == null ||
        now.difference(_lastBack!) > const Duration(seconds: 2)) {
      _lastBack = now;
      _toast(tr('pressBackExit'));
      return false;
    }
    return true;
  }

  void _pickSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B1240) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(tr('pickPhotoTitle'), style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: AnimatedSheetOption(
              icon: Icons.photo_library_outlined, label: tr('gallery'),
              onTap: () { Navigator.pop(ctx); _pick(ImageSource.gallery); })),
            const SizedBox(width: 12),
            Expanded(child: AnimatedSheetOption(
              icon: Icons.camera_alt_outlined, label: tr('camera'),
              onTap: () { Navigator.pop(ctx); _pick(ImageSource.camera); })),
          ]),
        ]),
      ),
    );
  }

  void _openLensPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.3, maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B1240) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(tr('lens'), style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Expanded(child: ListView.builder(
              controller: scrollCtrl,
              itemCount: kLenses.length,
              itemBuilder: (_, i) {
                final l = kLenses[i];
                final on = _lensId == l.id;
                return ListTile(
                  leading: Text(l.emoji, style: const TextStyle(fontSize: 26)),
                  title: Text(l.name, style: TextStyle(
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
                  subtitle: Text(l.brand, style: const TextStyle(fontSize: 12)),
                  trailing: on ? Icon(Icons.check_circle,
                    color: appSettings.accent) : null,
                  onTap: () { setLens(l.id); Navigator.pop(ctx); setState(() {}); _schedulePreview(); },
                );
              },
            )),
          ]),
        ),
      ),
    );
  }

  void _openAdjustPanel() => setState(() => _showAdjust = !_showAdjust);

  void _resetAdjust() {
    setState(() => _adj = presetForMode(_mode));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (d, r) async {
        if (d) return;
        final exit = await _handleBack();
        if (exit && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0A0818),
                     Color.lerp(appSettings.accent, Colors.black, 0.75)!,
                     const Color(0xFF0A0818)]
                  : [const Color(0xFFF5F3FF),
                     Color.lerp(appSettings.accent, Colors.white, 0.9)!,
                     const Color(0xFFF5F3FF)],
            ),
          ),
          child: SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;
                final previewHeight = isLandscape
                    ? 170.0
                    : (_original == null ? 280.0 : 320.0);

                return Column(children: [
                  _header(),
                  SizedBox(
                    height: previewHeight,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: _imageArea(),
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Column(children: [
                          _modeRow(),
                          const SizedBox(height: 16),
                          _intensityRow(),
                          const SizedBox(height: 14),
                          _actionRow(),
                          const SizedBox(height: 14),
                          _toolRow(),
                          if (_showAdjust) ...[
                            const SizedBox(height: 14),
                            _adjustPanel(),
                          ],
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
                                Expanded(child: Text(_error!,
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13))),
                              ]),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ),
                ]);
              },
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
        icon: const Icon(Icons.menu_rounded, size: 26)),
      const SizedBox(width: 4),
      AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final glow = 8 + _pulse.value * 12;
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                appSettings.accent, const Color(0xFF448AFF)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                color: appSettings.accent.withOpacity(0.5),
                blurRadius: glow, spreadRadius: 1)],
            ),
            child: const Icon(Icons.auto_awesome,
              color: Colors.white, size: 20),
          );
        },
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("EnhanceAI", style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          Text(tr('tagline'), style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 1)),
        ],
      )),
      if (_original != null)
        IconButton(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded, size: 24),
          tooltip: tr('startOver')),
    ]),
  );

  Widget _imageArea() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 500),
    switchInCurve: Curves.easeOutCubic,
    transitionBuilder: (child, anim) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween(begin: 0.96, end: 1.0).animate(anim),
        child: child)),
    child: KeyedSubtree(
      key: ValueKey('${_original?.length}-${_enhanced?.length}-$_loading'),
      child: _imageContent()),
  );

  Widget _imageContent() {
    if (_loading) return _loadingCard();
    if (_original == null) return _emptyCard();
    if (_enhanced != null) {
      return BeforeAfterSlider(before: _original!, after: _enhanced!);
    }
    final preview = _previewBytes ?? _original!;
    return Stack(children: [
      Positioned.fill(child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.memory(preview,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          width: double.infinity,
          height: double.infinity))),
      if (_previewBytes != null)
        Positioned(top: 10, left: 10, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8)),
          child: const Text('LIVE', style: TextStyle(
            color: Colors.white, fontSize: 10,
            fontWeight: FontWeight.w800, letterSpacing: 1.2)))),
    ]);
  }

  Widget _emptyCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _pickSheet,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.035) : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: appSettings.accent.withOpacity(0.15), width: 1.5)),
        child: Stack(children: [
          AnimatedBuilder(animation: _shimmer, builder: (_, __) => Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Transform.translate(
                offset: Offset(-300 + _shimmer.value * 700, 0),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                    colors: [Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(isDark ? 0.05 : 0.35),
                      Colors.white.withOpacity(0.0)]))))))),
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(animation: _pulse, builder: (_, __) => Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appSettings.accent.withOpacity(0.08 + _pulse.value * 0.08),
                border: Border.all(
                  color: appSettings.accent.withOpacity(0.25), width: 1.5)),
              child: Icon(Icons.add_photo_alternate_outlined, size: 42,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))),
            const SizedBox(height: 18),
            Text(tr('tapToPick'), style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 15, fontWeight: FontWeight.w500)),
          ])),
        ]),
      ),
    );
  }

  Widget _loadingCard() => Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [appSettings.accent.withOpacity(0.15),
          const Color(0xFF448AFF).withOpacity(0.15)]),
      border: Border.all(color: appSettings.accent.withOpacity(0.3), width: 1.5)),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 70, height: 70, child: Stack(alignment: Alignment.center, children: [
        SizedBox(width: 70, height: 70, child: CircularProgressIndicator(
          strokeWidth: 3, valueColor: AlwaysStoppedAnimation(appSettings.accent),
          backgroundColor: Colors.white12)),
        const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
      ])),
      const SizedBox(height: 22),
      Text(tr('enhancing'), style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600)),
    ])),
  );

  Widget _modeRow() {
    final current = modes.firstWhere((m) => m['id'] == _mode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(tr('enhanceMode').toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        ),
        GestureDetector(
          onTap: _openModeDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                appSettings.accent.withOpacity(0.15),
                const Color(0xFF448AFF).withOpacity(0.10)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: appSettings.accent.withOpacity(0.35), width: 1.4)),
            child: Row(children: [
              Icon(current['icon'] as IconData,
                color: appSettings.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(current['k'] as String),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              Icon(Icons.keyboard_arrow_down_rounded,
                color: appSettings.accent, size: 22),
            ]),
          ),
        ),
      ],
    );
  }

  void _openModeDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B1240) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.15))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          ...modes.map((m) {
            final on = _mode == m['id'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _mode = m['id'] as String;
                      _adj = presetForMode(_mode);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: on ? appSettings.accent.withOpacity(0.2)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: on
                        ? appSettings.accent.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.15))),
                    child: Row(children: [
                      Icon(m['icon'] as IconData, size: 22,
                        color: on ? appSettings.accent : null),
                      const SizedBox(width: 14),
                      Expanded(child: Text(tr(m['k'] as String),
                        style: TextStyle(fontSize: 15,
                          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                          color: on ? appSettings.accent : null))),
                      if (on) Icon(Icons.check_circle,
                        color: appSettings.accent, size: 22),
                    ]),
                  ),
                )),
            );
          }),
          const SizedBox(height: 4),
        ]),
      ));
  }

  Widget _intensityRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(tr('intensity').toUpperCase(), style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: appSettings.accent.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10)),
            child: Text("${(_intensity * 100).round()}%",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: appSettings.accent,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: appSettings.accent.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9)),
          child: Slider(value: _intensity, min: 0, max: 1,
            onChanged: (v) => setState(() => _intensity = v)),
        ),
      ]),
    );
  }

  Widget _actionRow() {
    final mode = modes.firstWhere((m) => m['id'] == _mode);
    final modeName = tr(mode['k'] as String);
    return Column(children: [
      Row(children: [
        Expanded(child: AnimatedPressButton(
          label: tr('gallery'), icon: Icons.photo_library_outlined,
          onTap: () => _pick(ImageSource.gallery), outlined: true)),
        const SizedBox(width: 10),
        Expanded(child: AnimatedPressButton(
          label: tr('camera'), icon: Icons.camera_alt_outlined,
          onTap: () => _pick(ImageSource.camera), outlined: true)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          flex: _enhanced != null ? 1 : 2,
          child: AnimatedPressButton(
            label: _loading ? tr('enhancing') : "${tr('enhance')} $modeName",
            icon: Icons.auto_fix_high,
            onTap: _original == null || _loading ? null : _enhance,
            gradient: true, loading: _loading)),
        if (_enhanced != null) ...[
          const SizedBox(width: 10),
          Expanded(child: AnimatedPressButton(
            label: tr('save'), icon: Icons.download_outlined,
            onTap: _save, outlined: true)),
        ],
      ]),
    ]);
  }

  Widget _toolRow() {
    int activeCount = 0;
    if (_lensId != 'none') activeCount++;
    if (_showAdjust) activeCount++;
    if (_bgBlurStrength > 0.05) activeCount++;
    if (_faceRestore) activeCount++;
    if (_expandRatio != null) activeCount++;
    if (_adj.rotation != 0 || _adj.flipH || _adj.flipV) activeCount++;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text('TOOLS', style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5))),
      GestureDetector(
        onTap: _openToolsDropdown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              appSettings.accent.withOpacity(0.15),
              const Color(0xFF448AFF).withOpacity(0.10)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: appSettings.accent.withOpacity(0.35), width: 1.4)),
          child: Row(children: [
            Icon(Icons.tune, color: appSettings.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(
              activeCount > 0 ? 'Tools ($activeCount active)' : 'Tools',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            Icon(Icons.keyboard_arrow_down_rounded,
              color: appSettings.accent, size: 22),
          ]),
        ),
      ),
    ]);
  }

  void _openToolsDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B1240) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('Tools', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _toolListTile(icon: Icons.camera_outlined, label: 'Lens',
                  value: _lensId == 'none' ? 'None' : activeLens.name,
                  active: _lensId != 'none',
                  onTap: () { Navigator.pop(ctx); _openLensPicker(); }),
                _toolListTile(icon: Icons.tune, label: 'Adjust',
                  value: _showAdjust ? 'Open' : 'Off', active: _showAdjust,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _showAdjust = !_showAdjust);
                  }),
                _toolListTile(icon: Icons.flip, label: 'Transform',
                  value: '${_adj.rotation.round()}°'
                    '${_adj.flipH ? " · H" : ""}'
                    '${_adj.flipV ? " · V" : ""}',
                  active: _adj.rotation != 0 || _adj.flipH || _adj.flipV,
                  onTap: () { Navigator.pop(ctx); _openTransformSheet(); }),
                _toolListTile(icon: Icons.blur_on, label: 'Background Blur',
                  value: _bgBlurStrength > 0.05
                    ? '${(_bgBlurStrength * 100).round()}%' : 'Off',
                  active: _bgBlurStrength > 0.05,
                  onTap: () { Navigator.pop(ctx); _openBlurSheet(); }),
                _toolListTile(icon: Icons.face_retouching_natural,
                  label: 'Face Fix',
                  value: _faceRestore ? 'On' : 'Off', active: _faceRestore,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _faceRestore = !_faceRestore);
                    _schedulePreview();
                  }),
                _toolListTile(icon: Icons.aspect_ratio, label: 'Expand Canvas',
                  value: _expandRatio ?? 'Original',
                  active: _expandRatio != null,
                  onTap: () { Navigator.pop(ctx); _openExpandSheet(); }),
                const SizedBox(height: 20),
              ])),
          ]))));
  }

  Widget _toolListTile({required IconData icon, required String label,
      required String value, required bool active, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: active ? appSettings.accent.withOpacity(0.2)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: active
                ? appSettings.accent.withOpacity(0.5)
                : Colors.grey.withOpacity(0.15))),
            child: Row(children: [
              Icon(icon, size: 22, color: active ? appSettings.accent : null),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: TextStyle(fontSize: 15,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? appSettings.accent : null))),
              Text(value, style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? appSettings.accent
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ]),
          ),
        )),
    );
  }

  void _openBlurSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1B1240)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Background Blur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detects faces and blurs everything else',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Strength',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Slider(
                          value: _bgBlurStrength,
                          min: 0,
                          max: 1,
                          activeColor: appSettings.accent,
                          onChanged: (v) { setS(() => setState(() => _bgBlurStrength = v)); _schedulePreview(); },
                        ),
                      ),
                      Text(
                        '${(_bgBlurStrength * 100).round()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openExpandSheet() {
    final ratios = ['16:9', '9:16', '1:1', '4:5'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B1240)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Expand Canvas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Fills empty space with a blurred version of your photo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ratioChip(ctx, null, 'Original'),
                  ...ratios.map((r) => _ratioChip(ctx, r, r)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ratioChip(BuildContext ctx, String? ratio, String label) {
    final on = _expandRatio == ratio;
    return GestureDetector(
      onTap: () {
        setState(() => _expandRatio = ratio);
        Navigator.pop(ctx);
        _schedulePreview();
      },
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: on ? appSettings.accent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? appSettings.accent : Colors.grey.withOpacity(0.2))),
        child: Text(label, style: TextStyle(
          fontWeight: FontWeight.w600,
          color: on ? appSettings.accent : null))),
    );
  }

  Widget _smallTool({required IconData icon, required String label,
      required VoidCallback onTap, required bool active}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 48,
        decoration: BoxDecoration(
          color: active
              ? appSettings.accent.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? appSettings.accent.withOpacity(0.6) : Colors.grey.withOpacity(0.15))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: active ? appSettings.accent : null),
          const SizedBox(width: 6),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: active ? appSettings.accent : null))),
        ]),
      ),
    );
  }

  void _openTransformSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B1240) : Colors.white,
            borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(tr('transform'), style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _transformTile(
                icon: Icons.flip, label: tr('flipH'),
                active: _adj.flipH,
                onTap: () { setS(() => setState(() => _adj.flipH = !_adj.flipH)); _schedulePreview(); })),
              const SizedBox(width: 10),
              Expanded(child: _transformTile(
                icon: Icons.flip_camera_android, label: tr('flipV'),
                active: _adj.flipV,
                onTap: () { setS(() => setState(() => _adj.flipV = !_adj.flipV)); _schedulePreview(); })),
              const SizedBox(width: 10),
              Expanded(child: _transformTile(
                icon: Icons.rotate_right, label: '90°',
                active: false,
                onTap: () { setS(() => setState(() {
                  _adj.rotation = (_adj.rotation + 90) % 360;
                })); _schedulePreview(); })),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Text(tr('rotate'), style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
              Expanded(child: Slider(
                value: _adj.rotation, min: 0, max: 360,
                divisions: 72,
                activeColor: appSettings.accent,
                onChanged: (v) { setS(() => setState(() => _adj.rotation = v)); _schedulePreview(); })),
              Text("${_adj.rotation.round()}°", style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _transformTile({required IconData icon, required String label,
      required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: active ? appSettings.accent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? appSettings.accent.withOpacity(0.6) : Colors.grey.withOpacity(0.15))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 22, color: active ? appSettings.accent : null),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: active ? appSettings.accent : null)),
        ]),
      ),
    );
  }

  Widget _adjustPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15))),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.tune, size: 18),
          const SizedBox(width: 8),
          Text(tr('adjust'), style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const Spacer(),
          TextButton.icon(
            onPressed: _resetAdjust,
            icon: const Icon(Icons.restore, size: 16),
            label: Text(tr('reset'), style: const TextStyle(fontSize: 12))),
        ]),
        const SizedBox(height: 4),
        _slider(tr('brightness'), _adj.brightness, -1, 1,
          (v) => setState(() => _adj.brightness = v)),
        _slider(tr('contrast'), _adj.contrast, -1, 1,
          (v) => setState(() => _adj.contrast = v)),
        _slider(tr('saturation'), _adj.saturation, -1, 1,
          (v) => setState(() => _adj.saturation = v)),
        _slider(tr('warmth'), _adj.warmth, -1, 1,
          (v) => setState(() => _adj.warmth = v)),
        _slider(tr('highlights'), _adj.highlights, -1, 1,
          (v) => setState(() => _adj.highlights = v)),
        _slider(tr('shadows'), _adj.shadows, -1, 1,
          (v) => setState(() => _adj.shadows = v)),
        _slider(tr('vignette'), _adj.vignette, 0, 1,
          (v) => setState(() => _adj.vignette = v)),
        _slider(tr('sharpness'), _adj.sharpness, 0, 1,
          (v) => setState(() => _adj.sharpness = v)),
      ]),
    );
  }

  Widget _slider(String label, double v, double min, double max, ValueChanged<double> onC) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: appSettings.accent,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.white,
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14)),
          child: Slider(value: v, min: min, max: max,
            onChanged: (val) { onC(val); _schedulePreview(); }))),
        SizedBox(width: 34, child: Text(v.toStringAsFixed(2),
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
      ]),
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
      backgroundColor: isDark ? const Color(0xFF14102E) : const Color(0xFFF5F3FF),
      child: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    appSettings.accent, const Color(0xFF448AFF)]),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("EnhanceAI", style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800)),
                Text(tr('tagline'), style: TextStyle(fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ]),
            ]),
          ),
          Divider(color: Colors.grey.withOpacity(0.15), height: 1),
          const SizedBox(height: 8),
          _item(context, Icons.menu_book_outlined, tr('guide'),
            () => _push(context, const GuideScreen())),
          _item(context, Icons.palette_outlined, tr('theme'),
            () => _sheetTheme(context)),
          _item(context, Icons.language_outlined, tr('language'),
            () => _sheetLanguage(context)),
          _item(context, Icons.color_lens_outlined, tr('accent'),
            () => _sheetAccent(context)),
          Divider(color: Colors.grey.withOpacity(0.15), height: 1),
          _item(context, Icons.info_outline, tr('about'),
            () => _push(context, const AboutScreen())),
          const Spacer(),
          Padding(padding: const EdgeInsets.all(16),
            child: Text(tr('version'), style: TextStyle(fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)))),
        ],
      )),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(12), onTap: onTap,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(children: [
            Icon(icon, size: 22), const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ])))));
  }

  void _push(BuildContext context, Widget s) {
    Navigator.pop(context);
    Navigator.push(context, PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => s,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child))));
  }

  void _sheetTheme(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
      builder: (_) => _sheetWrap(context, tr('theme'), [
        _sheetTile(context, icon: Icons.dark_mode_outlined, label: tr('dark'),
          selected: appSettings.themeMode == ThemeMode.dark,
          onTap: () { appSettings.setTheme(ThemeMode.dark); Navigator.pop(context); }),
        _sheetTile(context, icon: Icons.light_mode_outlined, label: tr('light'),
          selected: appSettings.themeMode == ThemeMode.light,
          onTap: () { appSettings.setTheme(ThemeMode.light); Navigator.pop(context); }),
        _sheetTile(context, icon: Icons.brightness_auto_outlined, label: tr('system'),
          selected: appSettings.themeMode == ThemeMode.system,
          onTap: () { appSettings.setTheme(ThemeMode.system); Navigator.pop(context); }),
      ]));
  }

  void _sheetLanguage(BuildContext context) {
    Navigator.pop(context);
    final langs = [
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
      {'code': 'ur', 'label': 'اردو', 'flag': '🇵🇰'},
      {'code': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
    ];
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
      builder: (_) => _sheetWrap(context, tr('language'),
        langs.map((l) => _sheetTile(context, icon: null, emoji: l['flag'],
          label: l['label']!, selected: appSettings.locale.languageCode == l['code'],
          onTap: () {
            appSettings.setLocale(Locale(l['code']!));
            Navigator.pop(context);
          })).toList()));
  }

  void _sheetAccent(BuildContext context) {
    Navigator.pop(context);
    final colors = [
      const Color(0xFF7C4DFF), const Color(0xFF00BFA5),
      const Color(0xFFFF6F00), const Color(0xFFE91E63),
      const Color(0xFF448AFF), const Color(0xFF43A047),
    ];
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1B1240) : Colors.white,
          borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(tr('accent'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Wrap(spacing: 16, runSpacing: 16, children: colors.map((c) {
            final on = appSettings.accent.value == c.value;
            return GestureDetector(
              onTap: () { appSettings.setAccent(c); Navigator.pop(context); },
              child: AnimatedContainer(duration: const Duration(milliseconds: 250),
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: Border.all(color: on ? Colors.white : Colors.transparent, width: 3),
                  boxShadow: [BoxShadow(color: c.withOpacity(on ? 0.6 : 0.3),
                    blurRadius: on ? 20 : 10, spreadRadius: on ? 2 : 0)]),
                child: on ? const Icon(Icons.check, color: Colors.white) : null));
          }).toList()),
        ]),
      ));
  }

  Widget _sheetWrap(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B1240) : Colors.white,
        borderRadius: BorderRadius.circular(24)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...children,
      ]));
  }

  Widget _sheetTile(BuildContext context, {IconData? icon, String? emoji,
      required String label, required bool selected, required VoidCallback onTap}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(14), onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? appSettings.accent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected
              ? appSettings.accent.withOpacity(0.5) : Colors.grey.withOpacity(0.15))),
          child: Row(children: [
            if (emoji != null) Text(emoji, style: const TextStyle(fontSize: 22))
            else if (icon != null) Icon(icon, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500))),
            if (selected) Icon(Icons.check_circle, color: appSettings.accent, size: 22),
          ])))));
  }
}

// ============================================================
//  GUIDE / ABOUT
// ============================================================
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final steps = [
      {'i': Icons.add_photo_alternate_outlined, 't': tr('step1Title'), 'b': tr('step1Body')},
      {'i': Icons.tune_outlined, 't': tr('step2Title'), 'b': tr('step2Body')},
      {'i': Icons.speed_outlined, 't': tr('step3Title'), 'b': tr('step3Body')},
      {'i': Icons.save_alt_outlined, 't': tr('step4Title'), 'b': tr('step4Body')},
    ];
    return Scaffold(
      appBar: AppBar(title: Text(tr('howToUse'))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(tr('guideIntro'), style: TextStyle(fontSize: 15,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 24),
        ...List.generate(steps.length, (i) {
          final s = steps[i];
          return Padding(padding: const EdgeInsets.only(bottom: 16),
            child: Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.04) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    appSettings.accent, const Color(0xFF448AFF)]),
                  borderRadius: BorderRadius.circular(12)),
                  child: Icon(s['i'] as IconData, color: Colors.white, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("${i + 1}. ${s['t']}", style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(s['b'] as String, style: TextStyle(fontSize: 13, height: 1.4,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65))),
                ])),
              ])));
        }),
      ]));
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('about'))),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 100, height: 100, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            appSettings.accent, const Color(0xFF448AFF)]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: appSettings.accent.withOpacity(0.4),
            blurRadius: 24, spreadRadius: 2)]),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 52)),
        const SizedBox(height: 20),
        const Text("EnhanceAI", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(tr('version'), style: TextStyle(fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        const SizedBox(height: 28),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15))),
          child: Text(tr('aboutBody'), textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)))),
      ])));
  }
}

// ============================================================
//  REUSABLE BUTTONS
// ============================================================
class AnimatedPressButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool outlined, gradient, loading;
  const AnimatedPressButton({super.key, required this.label, required this.icon,
    required this.onTap, this.outlined = false, this.gradient = false, this.loading = false});
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  bool get _en => widget.onTap != null || widget.loading;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(duration: const Duration(milliseconds: 250),
      opacity: _en ? 1.0 : 0.45,
      child: GestureDetector(
        onTapDown: (_) => _en ? _ctrl.forward() : null,
        onTapUp: (_) => _en ? _ctrl.reverse() : null,
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: ScaleTransition(scale: _scale, child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.gradient ? LinearGradient(colors: [
              appSettings.accent, const Color(0xFF448AFF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            color: widget.gradient ? null : (widget.outlined ? Colors.transparent
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7))),
            borderRadius: BorderRadius.circular(16),
            border: widget.outlined ? Border.all(
              color: appSettings.accent.withOpacity(0.4), width: 1.2) : null,
            boxShadow: widget.gradient && _en ? [BoxShadow(
              color: appSettings.accent.withOpacity(_ctrl.value > 0 ? 0.55 : 0.35),
              blurRadius: _ctrl.value > 0 ? 26 : 18,
              offset: const Offset(0, 6),
              spreadRadius: _ctrl.value > 0 ? 1 : 0)] : null),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (widget.loading)
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(
                strokeWidth: 2.2, color: Colors.white))
            else
              Icon(widget.icon, color: widget.outlined && !isDark
                ? Colors.black87 : Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.outlined && !isDark ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.2))),
          ]))),
      ));
  }
}

class AnimatedSheetOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const AnimatedSheetOption({super.key, required this.icon,
    required this.label, required this.onTap});
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) => _ctrl.reverse(),
    onTapCancel: () => _ctrl.reverse(),
    onTap: widget.onTap,
    child: ScaleTransition(scale: _scale, child: Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          appSettings.accent, const Color(0xFF448AFF)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: appSettings.accent.withOpacity(0.4),
          blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(widget.icon, color: Colors.white, size: 32),
        const SizedBox(height: 10),
        Text(widget.label, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ]))));
}

class AnimatedModeTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AnimatedModeTile({super.key, required this.icon, required this.label,
    required this.active, required this.onTap});
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 96,
        decoration: BoxDecoration(
          gradient: widget.active ? LinearGradient(colors: [
            appSettings.accent, const Color(0xFF448AFF)],
            begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          color: widget.active ? null : (isDark
            ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.active ? Colors.transparent
            : Colors.grey.withOpacity(0.2)),
          boxShadow: widget.active ? [BoxShadow(
            color: appSettings.accent.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 6))] : null),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, size: 26, color: widget.active ? Colors.white
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(widget.label, style: TextStyle(
            color: widget.active ? Colors.white
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
            fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500)),
        ]))));
  }
}

// ============================================================
//  BEFORE / AFTER SLIDER
// ============================================================
class BeforeAfterSlider extends StatefulWidget {
  final Uint8List before, after;
  const BeforeAfterSlider({super.key, required this.before, required this.after});
  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _pos = 0.5;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, box) {
    final w = box.maxWidth;
    final h = box.maxHeight.isFinite ? box.maxHeight : 340.0;
    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5),
          blurRadius: 24, offset: const Offset(0, 10))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: GestureDetector(
          onHorizontalDragUpdate: (d) =>
            setState(() => _pos = (d.localPosition.dx / w).clamp(0.0, 1.0)),
          child: Stack(children: [
            Positioned.fill(child: Image.memory(widget.after, fit: BoxFit.cover)),
            Positioned.fill(child: ClipRect(
              clipper: _LeftClipper(_pos),
              child: Image.memory(widget.before, fit: BoxFit.cover,
                width: w, height: h))),
            Positioned(left: _pos * w - 1, top: 0, bottom: 0,
              child: Container(width: 2.5, color: Colors.white)),
            Positioned(left: _pos * w - 22, top: h / 2 - 22,
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4),
                    blurRadius: 12, spreadRadius: 1)]),
                child: const Icon(Icons.compare_arrows,
                  size: 22, color: Colors.black87))),
            Positioned(top: 14, left: 14, child: _badge(tr('before'))),
            Positioned(top: 14, right: 14, child: _badge(tr('after'), on: true)),
          ]),
        ),
      ));
  });
  Widget _badge(String t, {bool on = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: on ? appSettings.accent.withOpacity(0.85) : Colors.black.withOpacity(0.65),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1)),
    child: Text(t, style: const TextStyle(
      color: Colors.white, fontSize: 11,
      fontWeight: FontWeight.w800, letterSpacing: 1.2)));
}

class _LeftClipper extends CustomClipper<Rect> {
  final double pos;
  _LeftClipper(this.pos);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * pos, size.height);
  @override
  bool shouldReclip(_LeftClipper old) => old.pos != pos;
}
