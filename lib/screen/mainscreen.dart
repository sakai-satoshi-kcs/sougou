import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../models/alarm.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Reminder> _todayReminders = [];
  List<Alarm> _todayAlarms = [];
  final List<Reminder> _reminders = [];
  final List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    DateTime today = DateTime.now();

    setState(() {
      _todayReminders = _reminders
          .where((reminder) =>
              reminder.date.year == today.year &&
              reminder.date.month == today.month &&
              reminder.date.day == today.day)
          .toList();

      _todayAlarms = _alarms
          .where((alarm) {
            DateTime alarmDateTime = DateTime(
              today.year, today.month, today.day, 
              alarm.time.hour, alarm.time.minute
            );
            return alarmDateTime.isAfter(today);
          })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日の予定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('アラーム', style: Theme.of(context).textTheme.titleLarge),
            _todayAlarms.isNotEmpty
            ? Column(
              children: _todayAlarms.map((alarm) => ListTile(
              title: Text('アラーム ${DateFormat('HH:mm').format(
                DateTime(0, 0, 0, alarm.time.hour, alarm.time.minute)
              )}'),
              leading: const Icon(Icons.alarm),
            )).toList(),
      )
    : const Text('今日のアラームはありません'),

            const Divider(),

            Text('リマインダー', style: Theme.of(context).textTheme.titleLarge),
            _todayReminders.isNotEmpty
                ? Column(
                    children: _todayReminders.map((reminder) => ListTile(
                          title: Text(reminder.name),
                          subtitle: Text(
                              DateFormat('yyyy/MM/dd HH:mm').format(reminder.date)),
                          leading: const Icon(Icons.notifications),
                        )).toList(),
                  )
                : const Text('今日のリマインダーはありません'),
          ],
        ),
      ),
    );
  }
}