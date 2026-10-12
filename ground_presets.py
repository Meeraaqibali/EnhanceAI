#!/usr/bin/env python3
import sys

PATH = 'lib/main.dart'
src = open(PATH, 'r', encoding='utf-8').read()
orig = len(src)

old = """ManualAdjust presetForMode(String mode) {
  final m = ManualAdjust();
  switch (mode) {
    case 'portrait':
      m.saturation = 0.08; m.contrast = 0.05; m.brightness = 0.03;
      m.highlights = -0.05; m.shadows = 0.10;
      break;
    case 'landscape':
      m.saturation = 0.20; m.contrast = 0.15; m.highlights = -0.10;
      m.shadows = 0.05; m.sharpness = 0.10;
      break;
    case 'old':
      m.saturation = -0.30; m.contrast = 0.20; m.warmth = 0.20;
      m.brightness = 0.05; m.shadows = 0.15; m.sharpness = 0.15;
      break;
    case 'vivid':
      m.saturation = 0.35; m.contrast = 0.20; m.warmth = 0.05;
      m.sharpness = 0.10;
      break;
    case 'soft':
      m.saturation = -0.10; m.contrast = -0.10; m.brightness = 0.10;
      m.shadows = 0.20;
      break;
  }
  return m;
}"""

new = """ManualAdjust presetForMode(String mode) {
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
}"""

n = src.count(old)
if n != 1:
    print(f'FAIL: anchor found {n} times (expected 1). Nothing written.')
    sys.exit(1)

src = src.replace(old, new, 1)
open(PATH, 'w', encoding='utf-8').write(src)
print(f'DONE. {orig} -> {len(src)} bytes.')
