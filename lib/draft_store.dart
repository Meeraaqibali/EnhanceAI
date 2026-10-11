import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class Draft {
  final String id;
  final String originalPath;
  final String enhancedPath;
  final String mode;
  final double intensity;
  final DateTime savedAt;

  Draft({
    required this.id,
    required this.originalPath,
    required this.enhancedPath,
    required this.mode,
    required this.intensity,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPath': originalPath,
        'enhancedPath': enhancedPath,
        'mode': mode,
        'intensity': intensity,
        'savedAt': savedAt.toIso8601String(),
      };

  factory Draft.fromJson(Map<String, dynamic> j) => Draft(
        id: j['id'] as String,
        originalPath: j['originalPath'] as String,
        enhancedPath: j['enhancedPath'] as String,
        mode: j['mode'] as String,
        intensity: (j['intensity'] as num).toDouble(),
        savedAt: DateTime.parse(j['savedAt'] as String),
      );
}

class DraftStore {
  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/enhance_drafts');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  static Future<List<Draft>> load() async {
    try {
      final d = await _dir();
      final idx = File('${d.path}/index.json');
      if (!await idx.exists()) return [];
      final raw = await idx.readAsString();
      final list = jsonDecode(raw) as List;
      return list.map((j) => Draft.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveIndex(List<Draft> drafts) async {
    final d = await _dir();
    final idx = File('${d.path}/index.json');
    await idx.writeAsString(
        jsonEncode(drafts.map((x) => x.toJson()).toList()));
  }

  static Future<Draft> add({
    required Uint8List original,
    required Uint8List enhanced,
    required String mode,
    required double intensity,
  }) async {
    final d = await _dir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final op = File('${d.path}/${id}_orig.jpg');
    final ep = File('${d.path}/${id}_enh.jpg');
    await op.writeAsBytes(original);
    await ep.writeAsBytes(enhanced);

    final draft = Draft(
      id: id,
      originalPath: op.path,
      enhancedPath: ep.path,
      mode: mode,
      intensity: intensity,
      savedAt: DateTime.now(),
    );
    final list = await load();
    list.insert(0, draft);
    await _saveIndex(list);
    return draft;
  }

  static Future<void> delete(Draft draft) async {
    try {
      await File(draft.originalPath).delete();
    } catch (_) {}
    try {
      await File(draft.enhancedPath).delete();
    } catch (_) {}
    final list = await load();
    list.removeWhere((x) => x.id == draft.id);
    await _saveIndex(list);
  }
}
