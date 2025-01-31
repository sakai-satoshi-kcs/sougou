import 'package:flutter/material.dart';
import '../models/reminder.dart'; // models から Reminder を明示的にインポート
import 'calendar.dart';
import 'reminder.dart';
import 'timetable.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Event> _todayEvents = [];
  List<Reminder> _todayReminders = [];
  List<String> _todayTimetable = [];
  final Map<DateTime, List<Event>> _events = {};
  final List<Reminder> _reminders = [];
  List<List<String?>> timetable = List.generate(5, (_) => List.filled(4, null));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    DateTime today = DateTime.now();
    setState(() {
      _todayEvents = _events[today] ?? [];
      _todayReminders = _reminders
          .where((reminder) =>
              reminder.date.year == today.year &&
              reminder.date.month == today.month &&
              reminder.date.day == today.day)
          .toList();
      int weekdayIndex = today.weekday - 1;
      _todayTimetable = (weekdayIndex >= 0 && weekdayIndex < timetable.length)
          ? timetable[weekdayIndex].whereType<String>().toList()
          : [];
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
            Text('カレンダーの予定', style: Theme.of(context).textTheme.titleLarge),
            ..._todayEvents.map((event) => ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      '開始時間: ${DateFormat('HH:mm').format(event.startDate)}'),
                )),
            const Divider(),
            Text('リマインダー', style: Theme.of(context).textTheme.titleLarge),
            ..._todayReminders.map((reminder) => ListTile(
                  title: Text(reminder.name ?? '名称未設定'),
                  subtitle: Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(reminder.date)),
                )),
            const Divider(),
            Text('今日の時間割', style: Theme.of(context).textTheme.titleLarge),
            ..._todayTimetable.map((subject) => ListTile(title: Text(subject))),
          ],
        ),
      ),
    );
  }
}