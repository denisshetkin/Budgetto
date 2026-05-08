import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiagnosticsLogEntry {
  const DiagnosticsLogEntry({
    required this.timestamp,
    required this.category,
    required this.message,
    required this.details,
  });

  final DateTime timestamp;
  final String category;
  final String message;
  final Map<String, String> details;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'category': category,
    'message': message,
    'details': details,
  };

  static DiagnosticsLogEntry fromJson(Map<String, dynamic> json) {
    return DiagnosticsLogEntry(
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      category: json['category'] as String? ?? 'general',
      message: json['message'] as String? ?? '',
      details: Map<String, String>.from(json['details'] as Map? ?? const {}),
    );
  }
}

class DiagnosticsLogger {
  DiagnosticsLogger._();

  static const String _storageKey = 'support_diagnostics_log_entries';
  static const int _maxEntries = 200;
  static final DiagnosticsLogger instance = DiagnosticsLogger._();

  final List<DiagnosticsLogEntry> _entries = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final rawEntries = prefs.getStringList(_storageKey) ?? const [];
    for (final raw in rawEntries) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _entries.add(DiagnosticsLogEntry.fromJson(decoded));
      } catch (_) {
        // Ignore malformed saved diagnostics entries.
      }
    }
    _initialized = true;
  }

  Future<void> log(
    String category,
    String message, {
    Map<String, Object?> details = const {},
  }) async {
    await initialize();
    final entry = DiagnosticsLogEntry(
      timestamp: DateTime.now(),
      category: category,
      message: message,
      details: _sanitizeDetails(details),
    );
    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    await _persist();
  }

  List<DiagnosticsLogEntry> entries() {
    return List.unmodifiable(_entries);
  }

  Future<void> clear() async {
    await initialize();
    _entries.clear();
    await _persist();
  }

  Future<void> shareReport({
    required String report,
    required String fileName,
    String? subject,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(report, flush: true);
    await Share.shareXFiles([XFile(file.path)], subject: subject);
  }

  Map<String, String> _sanitizeDetails(Map<String, Object?> details) {
    final result = <String, String>{};
    for (final entry in details.entries) {
      result[entry.key] = _sanitizeValue(entry.value);
    }
    return result;
  }

  String _sanitizeValue(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Iterable) {
      return value.map(_sanitizeValue).join(', ');
    }
    if (value is Map) {
      final buffer = StringBuffer();
      var first = true;
      for (final entry in value.entries) {
        if (!first) {
          buffer.write(', ');
        }
        first = false;
        buffer.write('${entry.key}=${_sanitizeValue(entry.value)}');
      }
      return buffer.toString();
    }
    return value.toString();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }
}
