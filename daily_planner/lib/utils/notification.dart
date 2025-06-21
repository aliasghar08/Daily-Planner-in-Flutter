import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static bool _initialized = false;

  
  static Future<void> initialize() async {
    if (_initialized) return;

    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for task reminders',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: const Color(0xFF9D50DD),
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ], debug: true);

    _initialized = true;
  }

 
  static Future<void> requestPermissionIfNeeded() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await initialize();

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          year: scheduledTime.year,
          month: scheduledTime.month,
          day: scheduledTime.day,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: 0,
          millisecond: 0,
          preciseAlarm: true, 
          repeats: false,
        ),
      );

      print("✅ Notification scheduled at $scheduledTime");
    } catch (e) {
      print("❌ Error scheduling notification: $e");
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      print("🔕 Notification with ID $id cancelled.");
    } catch (e) {
      print("❌ Error cancelling notification: $e");
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
      print("🧹 All notifications cancelled.");
    } catch (e) {
      print("❌ Error cancelling all notifications: $e");
    }
  }
}
