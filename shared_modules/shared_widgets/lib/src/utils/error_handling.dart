import 'package:flutter/material.dart';
import 'dart:io';
import 'package:stack_trace/stack_trace.dart';

void showErrorSnackBar(BuildContext context, String message,
    {Color color = Colors.red}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}

Future<void> logError(String message,
    {dynamic error, StackTrace? stackTrace}) async {
  try {
    // استخدم مجلد مؤقت بدل path_provider
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/app_log.txt');

    final timestamp = DateTime.now().toIso8601String();
    String logMessage = '$timestamp - $message';

    if (error != null) {
      logMessage += '\nError: $error';
      final trace = stackTrace ??
          (error is Error ? error.stackTrace : StackTrace.current);
      if (trace != null) {
        final formattedStackTrace = Chain.forTrace(trace).toString();
        logMessage += '\nStack Trace:\n$formattedStackTrace';
      }
    }

    logMessage += '\n---------------------------\n';
    await file.writeAsString(logMessage, mode: FileMode.append);
  } catch (e) {
    debugPrint('Failed to log error: $e');
  }
}
