import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

// ============================================================
//  HEURISTIC "FACE" REGION (no ML — center-weighted)
// ============================================================
List<Map<String, num>> heuristicFaceRegions(int width, int height) {
  // Assume a portrait-style subject near the center
  final w = width * 0.55;
  final h = height * 0.55;
  final x = (width - w) / 2;
  final y = height * 0.15;
  return [
    {'x': x, 'y': y, 'w': w, 'h': h},
  ];
}

// ============================================================
//  BACKGROUND BLUR (center focus)
// ============================================================
Uint8List _applyFaceBlur(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final strength = (args['strength'] as num).toDouble().clamp(0.0, 1.0);

  var src = img.decodeImage(bytes);
  if (src == null) throw Exception('decode');
  src = img.bakeOrientation(src);

  const maxDim = 1400;
  if (src.width > maxDim || src.height > maxDim) {
    final r = maxDim / (src.width > src.height ? src.width : src.height);
    src = img.copyResize(src,
        width: (src.width * r).round(),
        height: (src.height * r).round(),
        interpolation: img.Interpolation.average);
  }

  final w = src.width, h = src.height;
  final rects = heuristicFaceRegions(w, h);

  // Build soft mask: 255 = keep sharp, 0 = blur
  final mask = Uint8List(w * h)..fillRange(0, w * h, 0);

  for (final r in rects) {
    final cx = r['x']!.toDouble() + r['w']!.toDouble() / 2;
    final cy = r['y']!.toDouble() + r['h']!.toDouble() / 2;
    final rx = r['w']!.toDouble() * 0.8;
    final ry = r['h']!.toDouble() * 0.9;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final dx = (x - cx) / rx;
        final dy = (y - cy) / ry;
        final d2 = dx * dx + dy * dy;
        if (d2 < 1.0) {
          final v = ((1.0 - d2) * 255).clamp(0, 255).toInt();
          final idx = y * w + x;
          if (v > mask[idx]) mask[idx] = v;
        }
      }
    }
  }

  final blurred = img.gaussianBlur(src, radius: (strength * 14).round());
  final out = img.Image(width: w, height: h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final m = mask[y * w + x] / 255.0;
      final sharp = src.getPixel(x, y);
      final soft = blurred.getPixel(x, y);
      out.setPixelRgb(x, y,
          (sharp.r * m + soft.r * (1 - m)).clamp(0, 255).toInt(),
          (sharp.g * m + soft.g * (1 - m)).clamp(0, 255).toInt(),
          (sharp.b * m + soft.b * (1 - m)).clamp(0, 255).toInt());
    }
  }

  return Uint8List.fromList(img.encodeJpg(out, quality: 95));
}

Future<Uint8List> applyFaceBlur(Uint8List bytes, double strength) {
  return compute(_applyFaceBlur, {'bytes': bytes, 'strength': strength});
}

// ============================================================
//  CANVAS EXPANSION
// ============================================================
Uint8List _expandCanvas(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final targetW = args['targetW'] as int;
  final targetH = args['targetH'] as int;
  final blurBg = (args['blur'] as num).toDouble();

  var src = img.decodeImage(bytes);
  if (src == null) throw Exception('decode');
  src = img.bakeOrientation(src);

  final srcRatio = src.width / src.height;
  final targetRatio = targetW / targetH;
  int fitW, fitH;
  if (srcRatio > targetRatio) {
    fitW = targetW;
    fitH = (targetW / srcRatio).round();
  } else {
    fitH = targetH;
    fitW = (targetH * srcRatio).round();
  }
  final fitted = img.copyResize(src,
      width: fitW, height: fitH, interpolation: img.Interpolation.cubic);

  final bgSource = img.copyResize(src,
      width: targetW, height: targetH, interpolation: img.Interpolation.cubic);
  final bg = blurBg > 0
      ? img.gaussianBlur(bgSource, radius: (blurBg * 40).round())
      : bgSource;

  final canvas = img.Image(width: targetW, height: targetH);
  for (int y = 0; y < targetH; y++) {
    for (int x = 0; x < targetW; x++) {
      final p = bg.getPixel(x, y);
      canvas.setPixelRgb(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt());
    }
  }

  final ox = (targetW - fitW) ~/ 2;
  final oy = (targetH - fitH) ~/ 2;
  for (int y = 0; y < fitH; y++) {
    for (int x = 0; x < fitW; x++) {
      final p = fitted.getPixel(x, y);
      canvas.setPixelRgb(ox + x, oy + y, p.r.toInt(), p.g.toInt(), p.b.toInt());
    }
  }

  return Uint8List.fromList(img.encodeJpg(canvas, quality: 95));
}

Future<Uint8List> expandCanvas(Uint8List bytes, int targetW, int targetH,
    {double blur = 0.6}) {
  return compute(_expandCanvas, {
    'bytes': bytes, 'targetW': targetW, 'targetH': targetH, 'blur': blur,
  });
}

// ============================================================
//  FACE-AWARE RESTORE (center-weighted)
// ============================================================
Uint8List _faceRestore(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final amount = (args['amount'] as num).toDouble().clamp(0.0, 1.0);

  var src = img.decodeImage(bytes);
  if (src == null) throw Exception('decode');
  src = img.bakeOrientation(src);

  final w = src.width, h = src.height;
  final rects = heuristicFaceRegions(w, h);

  final base = img.gaussianBlur(src, radius: 1);
  final sharp = img.convolution(base, filter: [
    0, -1, 0,
    -1, 5, -1,
    0, -1, 0,
  ], div: 1);
  final boosted = img.adjustColor(sharp,
      contrast: 1.0 + 0.15 * amount,
      saturation: 1.0 + 0.10 * amount);

  final out = img.Image(width: w, height: h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      double weight = 0.35;
      for (final r in rects) {
        final rx = r['w']!.toDouble() * 0.9;
        final ry = r['h']!.toDouble() * 0.9;
        final cx = r['x']!.toDouble() + r['w']!.toDouble() / 2;
        final cy = r['y']!.toDouble() + r['h']!.toDouble() / 2;
        final dx = (x - cx) / rx;
        final dy = (y - cy) / ry;
        final d2 = dx * dx + dy * dy;
        if (d2 < 1.0) {
          final f = (1.0 - d2).clamp(0.0, 1.0);
          if (f + 0.35 > weight) weight = (f + 0.35).clamp(0.0, 1.0);
        }
      }
      final o = src.getPixel(x, y);
      final b = boosted.getPixel(x, y);
      out.setPixelRgb(x, y,
          (o.r * (1 - weight) + b.r * weight).clamp(0, 255).toInt(),
          (o.g * (1 - weight) + b.g * weight).clamp(0, 255).toInt(),
          (o.b * (1 - weight) + b.b * weight).clamp(0, 255).toInt());
    }
  }

  return Uint8List.fromList(img.encodeJpg(out, quality: 95));
}

Future<Uint8List> faceAwareRestore(Uint8List bytes, double amount) {
  return compute(_faceRestore, {'bytes': bytes, 'amount': amount});
}
