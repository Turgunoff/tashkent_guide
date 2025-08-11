import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class LogService {
  static String _format(String level, String tag, String message) {
    final ts = DateTime.now().toIso8601String();
    return '[$ts][$level][$tag] $message';
  }

  static void info(String tag, String message, {Map<String, Object?>? data}) {
    final line = _format('INFO', tag, message);
    if (data != null && data.isNotEmpty) {
      developer.log('$line | data=$data');
    } else {
      developer.log(line);
    }
  }

  static void warn(String tag, String message, {Map<String, Object?>? data}) {
    final line = _format('WARN', tag, message);
    if (data != null && data.isNotEmpty) {
      developer.log('$line | data=$data');
    } else {
      developer.log(line);
    }
  }

  static void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    final line = _format('ERROR', tag, message);
    if (kDebugMode) {
      developer.log(
        '$line | data=${data ?? {}}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
