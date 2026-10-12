#!/usr/bin/env python3
import sys

PATH = 'lib/main.dart'
src = open(PATH, 'r', encoding='utf-8').read()
orig = len(src)

old = """  Future<bool> _handleBack() async {
    if (_original != null || _enhanced != null) { _reset(); return false; }
    final now = DateTime.now();
    if (_lastBack == null || now.difference(_lastBack!) > const Duration(seconds: 2)) {
      _lastBack = now; _toast(tr('pressBackExit')); return false;
    }
    return true;
  }"""

new = """  Future<bool> _handleBack() async {
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
              ? 'Your enhanced photo hasn\\'t been saved. It will be lost.'
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
  }"""

n = src.count(old)
if n != 1:
    print(f'FAIL: anchor found {n} times (expected 1). Nothing written.')
    sys.exit(1)

src = src.replace(old, new, 1)
open(PATH, 'w', encoding='utf-8').write(src)
print(f'DONE. {orig} -> {len(src)} bytes.')
