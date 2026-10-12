#!/usr/bin/env python3
import sys

PATH = 'lib/main.dart'
src = open(PATH, 'r', encoding='utf-8').read()
orig = len(src)

old = "        home: const AnimatedSplash(),"

new = """        builder: (context, child) {
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
        home: const AnimatedSplash(),"""

n = src.count(old)
if n != 1:
    print(f'FAIL: anchor found {n} times (expected 1). Nothing written.')
    sys.exit(1)

src = src.replace(old, new, 1)
open(PATH, 'w', encoding='utf-8').write(src)
print(f'DONE. {orig} -> {len(src)} bytes.')
