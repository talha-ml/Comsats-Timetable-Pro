import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../models/timetable_model.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 1. Notifications Initialize Karna
  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 2. Notification Permission (Naye Version ke liye Update)
  Future<void> requestPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  // 3. Purane Alarms Cancel Karna
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // 4. Multiple Reminders (30, 15, 5 min) schedule karna
  Future<void> scheduleClassReminders(List<TimetableModel> userClasses) async {
    await cancelAllNotifications();

    int notificationId = 0;
    // Teen alag-alag alerts ke intervals
    final List<int> intervals = [30, 15, 5];

    for (var cls in userClasses) {
      int dayOfWeek = _getDayOfWeek(cls.dayOfWeek);
      if (dayOfWeek == -1) continue;

      DateTime? parsedTime = _parseTime(cls.startTime);
      if (parsedTime == null) continue;

      for (int minutesBefore in intervals) {
        // Class se X minute pehle ka time set karna
        DateTime reminderTime = parsedTime.subtract(Duration(minutes: minutesBefore));

        await _scheduleWeeklyNotification(
          id: notificationId++,
          title: 'Class in $minutesBefore Minutes!',
          body: '${cls.subjectName} in Room ${cls.roomNumber} starts at ${cls.startTime}.',
          day: dayOfWeek,
          hour: reminderTime.hour,
          minute: reminderTime.minute,
        );
      }
    }
  }

  // Weekly Alarm Logic
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int day,
    required int hour,
    required int minute,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfDayAndTime(day, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'timetable_channel_v3',
            'Urgent Class Reminders',
            channelDescription: 'Multi-interval notifications for upcoming classes',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint("Scheduling Error: $e");
    }
  }

  // Helper: Agle aane wale specific din aur time ko calculate karna
  tz.TZDateTime _nextInstanceOfDayAndTime(int day, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Helper: Din ko Number mein badalna
  int _getDayOfWeek(String day) {
    switch (day.toLowerCase().trim()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return -1;
    }
  }

  // Helper: Time text ko parse karna
  DateTime? _parseTime(String timeString) {
    try {
      return DateFormat("h:mm a").parse(timeString.trim());
    } catch (e) {
      return null;
    }
  }
}