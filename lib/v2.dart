import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
//объект уведомления - экземпляр
  late FlutterLocalNotificationsPlugin localNotifications;

  @override
  void initState() {
    super.initState();

    //object for Android settings
    const androidInitialize = AndroidInitializationSettings('ic_launcher');
    //object for IOS settings
    const iOSInitialize = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    // all information
    const initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    //we create local notofication
    localNotifications = FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Click the button to receive.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showEveryDay,
        child: const Icon(Icons.notifications),
      ),
    );
  }

  Future<NotificationDetails> _showNotification() async {
    const androidDetails = AndroidNotificationDetails("ID", "Name notification",
        importance: Importance.high,
        channelDescription: "content notifocation");

    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> showEveryDay() async {
    final details = await _showNotification();
    tz.initializeTimeZones();

    await localNotifications.zonedSchedule(
        0, 'Name', 'body', _nextInstanceOfTenAM(), details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidAllowWhileIdle: true);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
