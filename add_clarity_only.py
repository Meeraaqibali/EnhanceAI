#!/usr/bin/env python3
import sys

PATH = 'lib/main.dart'
src = open(PATH, 'r', encoding='utf-8').read()
orig = len(src)
changes = []

def rep(old, new, label):
    global src
    n = src.count(old)
    if n == 0:
        print(f'\n*** FAIL [{label}] ***\nAnchor not found.')
        print('Anchor was:\n' + repr(old[:220]))
        sys.exit(1)
    if n > 1:
        print(f'\n*** FAIL [{label}] ***\nAnchor appears {n} times.')
        sys.exit(1)
    src = src.replace(old, new, 1)
    changes.append(label)
    print(f'  OK  {label}')

print('Adding clarity infrastructure...')

# 1. ManualAdjust field
rep("""  double rotation = 0;     // 0..360
  bool flipH = false;
  bool flipV = false;
""",
"""  double rotation = 0;     // 0..360
  bool flipH = false;
  bool flipV = false;
  double clarity = 0;      // 0..1 — mid-tone local contrast
""",
    'ManualAdjust.clarity field')

# 2. clone()
rep("""    ..rotation = rotation
    ..flipH = flipH
    ..flipV = flipV;
""",
"""    ..rotation = rotation
    ..flipH = flipH
    ..flipV = flipV
    ..clarity = clarity;
""",
    'clone() clarity')

# 3. isDefault
rep("      rotation == 0 && !flipH && !flipV;",
    "      rotation == 0 && !flipH && !flipV && clarity == 0;",
    'isDefault clarity')

# 4. toMap()
rep("    'rotation': rotation, 'flipH': flipH, 'flipV': flipV,\n  };",
    "    'rotation': rotation, 'flipH': flipH, 'flipV': flipV,\n    'clarity': clarity,\n  };",
    'toMap clarity')

# 5. _processImage reads clarity
rep("""  double fade = lens.fade;
  c *= lens.contrast;
  s *= lens.saturation;
""",
"""  double fade = lens.fade;
  double clarity = (adj['clarity'] as num?)?.toDouble() ?? 0.0;
  c *= lens.contrast;
  s *= lens.saturation;
""",
    '_processImage read clarity')

# 6. Clarity pipeline stage (before Vignette)
rep("""  // Vignette
  if (vg > 0) {""",
"""  // Clarity — mid-tone local contrast (soft blur + unsharp on mid-freq)
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
  if (vg > 0) {""",
    'clarity pipeline stage')

open(PATH, 'w', encoding='utf-8').write(src)
print(f'\nDONE. Applied {len(changes)} edits. {orig} -> {len(src)} bytes.')
