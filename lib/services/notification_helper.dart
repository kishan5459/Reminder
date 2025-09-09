import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    tzl.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(initializationSettings);

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      "Reminders",
      description: "Channel for Reminder Notifications",
      playSound: true,
      enableLights: true,
      ledColor: Colors.teal,
      importance: Importance.high,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 2000]),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String category,
    DateTime scheduledTime,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      "reminder_channel",
      "Reminders",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    if (scheduledTime.isBefore(DateTime.now())) {
      // do nothing
    } else {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        category,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
