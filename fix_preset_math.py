#!/usr/bin/env python3
import sys

PATH = 'lib/main.dart'
src = open(PATH, 'r', encoding='utf-8').read()
orig = len(src)

old = """  double b = ((preset.brightness) * k) + (adj['brightness'] as num) * 0.5;
  double c = 1.0 + ((preset.contrast) * k) + (adj['contrast'] as num) * 0.6;
  double s = 1.0 + ((preset.saturation) * k) + (adj['saturation'] as num) * 0.8;
  double w = ((preset.warmth) * k) + (adj['warmth'] as num) * 0.5 + lens.warmth;
  double vg = (adj['vignette'] as num) * 1.0 + lens.vignette;
  double sh = (adj['sharpness'] as num) * 1.0 + lens.sharpness;
  double hl = ((preset.highlights) * k) + (adj['highlights'] as num) * 0.5;
  double sd = ((preset.shadows) * k) + (adj['shadows'] as num) * 0.5;
  double fade = lens.fade;
  double clarity = (adj['clarity'] as num?)?.toDouble() ?? 0.0;"""

new = """  // adj ALREADY contains the mode preset (it is reset to presetForMode()
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
  double clarity = ((adj['clarity'] as num?)?.toDouble() ?? 0.0) * k;"""

n = src.count(old)
if n != 1:
    print(f'FAIL: anchor found {n} times (expected 1). Nothing written.')
    sys.exit(1)

src = src.replace(old, new, 1)
open(PATH, 'w', encoding='utf-8').write(src)
print(f'DONE. {orig} -> {len(src)} bytes.')
