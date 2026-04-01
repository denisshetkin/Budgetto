import 'dart:ui' as ui;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/generated/app_localizations.dart';

class LocalNotifications {
  LocalNotifications._();

  static final LocalNotifications instance = LocalNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to UTC if local timezone is unavailable.
    }
    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    bool granted = true;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted && (result ?? false);
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final result = await android.requestNotificationsPermission();
      granted = granted && (result ?? true);
    }
    return granted;
  }

  Future<void> schedulePlanned({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await initialize();
    final l10n = lookupAppLocalizations(ui.PlatformDispatcher.instance.locale);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'planned_reminders',
        l10n.notificationChannelPlannedName,
        channelDescription: l10n.notificationChannelPlannedDescription,
        icon: 'ic_notification',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await initialize();
    final l10n = lookupAppLocalizations(ui.PlatformDispatcher.instance.locale);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'custom_reminders',
        l10n.notificationChannelReminderName,
        channelDescription: l10n.notificationChannelReminderDescription,
        icon: 'ic_notification',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showFamilyTransaction({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    final l10n = lookupAppLocalizations(ui.PlatformDispatcher.instance.locale);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'family_transactions',
        l10n.notificationChannelFamilyName,
        channelDescription: l10n.notificationChannelFamilyDescription,
        icon: 'ic_notification',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
