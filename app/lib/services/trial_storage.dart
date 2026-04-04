import 'package:flutter/services.dart';

class TrialStorage {
  static const MethodChannel _channel = MethodChannel(
    'com.denshetkin.budgetto/trial_storage',
  );

  static Future<int?> readTrialStartedAtMillis() async {
    try {
      return await _channel.invokeMethod<int>('readTrialStartedAtMillis');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static Future<void> writeTrialStartedAtMillis(int value) async {
    try {
      await _channel.invokeMethod<void>('writeTrialStartedAtMillis', {
        'value': value,
      });
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
