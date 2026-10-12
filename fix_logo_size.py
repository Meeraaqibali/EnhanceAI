#!/usr/bin/env python3
import sys

PATH = 'lib/main.dart'
src = open(PATH, 'r', encoding='utf-8').read()
orig = len(src)

old = """          final glow = 8 + _pulse.value * 12;
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
          );"""

new = """          final glow = 6 + _pulse.value * 8;
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                appSettings.accent, const Color(0xFF448AFF)]),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(
                color: appSettings.accent.withOpacity(0.5),
                blurRadius: glow, spreadRadius: 1)],
            ),
            child: const Icon(Icons.auto_awesome,
              color: Colors.white, size: 18),
          );"""

n = src.count(old)
if n != 1:
    print(f'FAIL: anchor found {n} times (expected 1). Nothing written.')
    sys.exit(1)

src = src.replace(old, new, 1)
open(PATH, 'w', encoding='utf-8').write(src)
print(f'DONE. {orig} -> {len(src)} bytes.')
