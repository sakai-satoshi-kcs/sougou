import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> _alarms = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _setAlarm(TimeOfDay selectedTime) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    final tz.TZDateTime scheduledTZTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    int alarmId = _alarms.length;

    await _notificationsPlugin.zonedSchedule(
      alarmId,
      'アラーム',
      '設定した時間になりました',
      scheduledTZTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _alarms = List.from(_alarms)
        ..add({'id': alarmId, 'time': selectedTime, 'enabled': true});
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    TimeOfDay defaultPicked =
        TimeOfDay(hour: now.hour, minute: now.minute); // 🔹 修正: デフォルト値を設定
    TimeOfDay? picked;

    picked = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay tempPicked = defaultPicked; // 🔹 修正: 一時変数でデフォルト値を保持
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    tempPicked =
                        TimeOfDay(hour: newTime.hour, minute: newTime.minute);
                  },
                ),
              ),
              CupertinoButton(
                child: const Text("OK", style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.of(context)
                      .pop(tempPicked); // 🔹 修正: `null` にならないようにする
                },
              )
            ],
          ),
        );
      },
    );

    if (picked != null) {
      _setAlarm(picked); // 🔹 `picked!` を使用せず、確実に `TimeOfDay` 型になる
    }
  }

  void _toggleAlarm(int index) {
    setState(() {
      _alarms[index]['enabled'] = !_alarms[index]['enabled'];
    });
  }

  void _removeAlarm(int index) {
    setState(() {
      _alarms = List.from(_alarms)..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('アラーム'),
        trailing: GestureDetector(
          onTap: () => _selectTime(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: _alarms.length,
          itemBuilder: (context, index) {
            final alarm = _alarms[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${alarm['time'].hour.toString().padLeft(2, '0')}:${alarm['time'].minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('アラーム',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      CupertinoSwitch(
                        value: alarm['enabled'],
                        onChanged: (value) => _toggleAlarm(index),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.delete,
                            color: Colors.red),
                        onPressed: () => _removeAlarm(index),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
