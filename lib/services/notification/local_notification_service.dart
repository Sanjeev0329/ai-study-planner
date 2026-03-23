import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  static Future<void> scheduleReminder({
    required int id, required String title, required String body, required DateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id, title, body, tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('prepwise_channel', 'Study Reminders',
            channelDescription: 'Daily reminders', importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showInstant({required String title, required String body}) async {
    await _plugin.show(0, title, body, const NotificationDetails(
      android: AndroidNotificationDetails('prepwise_channel', 'Study Reminders', importance: Importance.high),
    ));
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
