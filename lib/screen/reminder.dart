import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones(); // タイムゾーン初期化
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Map<String, dynamic> reminder) async {
    final DateTime reminderTime = DateTime(
      reminder['date'].year,
      reminder['date'].month,
      reminder['date'].day,
      reminder['time'].hour,
      reminder['time'].minute,
    ).subtract(Duration(minutes: 15));

    if (reminderTime.isAfter(DateTime.now())) {
      final tz.TZDateTime tzReminderTime =
          tz.TZDateTime.from(reminderTime, tz.local);

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'reminder_channel', // チャンネルID
        'リマインダー通知', // チャンネル名
        channelDescription: 'リマインダーの通知を受け取ります',
        importance: Importance.high,
        priority: Priority.high,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.zonedSchedule(
        reminder.hashCode, // 一意のID
        'リマインダー: ${reminder['name']}',
        '予定時刻の15分前です。',
        tzReminderTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('リマインダー')),
      body: _reminders.isEmpty
          ? Center(child: Text('リマインダーがありません'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return GestureDetector(
                  onTap: () => _showReminderDetails(reminder, index),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: _getPriorityColor(reminder['priority']),
                          width: 3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          reminder['name'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '日付: ${DateFormat('yyyy/MM/dd').format(reminder['date'])}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '時刻: ${reminder['time'].format(context)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddReminderDialog({Map<String, dynamic>? reminder, int? index}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController =
        TextEditingController(text: reminder?['name'] ?? '');
    final _memoController =
        TextEditingController(text: reminder?['memo'] ?? '');
    final _urlController = TextEditingController(text: reminder?['url'] ?? '');
    DateTime? selectedDate = reminder?['date'];
    TimeOfDay? selectedTime = reminder?['time'];
    String repeat = reminder?['repeat'] ?? 'なし';
    String priority = reminder?['priority'] ?? '低';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(reminder == null ? 'リマインダーを追加' : 'リマインダーを編集'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: '名前'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '名前を入力してください';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _memoController,
                    decoration: InputDecoration(labelText: 'メモ'),
                  ),
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(labelText: 'URL'),
                    keyboardType: TextInputType.url,
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text(selectedDate == null
                        ? '日付を選択'
                        : DateFormat('yyyy/MM/dd').format(selectedDate!)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(selectedTime == null
                        ? '時刻を選択'
                        : selectedTime!.format(context)),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: repeat,
                    decoration: InputDecoration(labelText: '繰り返し'),
                    items: ['なし', '毎日', '毎週', '毎月']
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        repeat = value!;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: InputDecoration(labelText: '優先順位'),
                    items: ['低', '中', '高']
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        priority = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    selectedDate != null &&
                    selectedTime != null) {
                  final newReminder = {
                    'name': _nameController.text,
                    'memo': _memoController.text,
                    'url': _urlController.text,
                    'date': selectedDate,
                    'time': selectedTime,
                    'repeat': repeat,
                    'priority': priority,
                  };

                  setState(() {
                    if (index == null) {
                      _reminders.add(newReminder);
                    } else {
                      _reminders[index] = newReminder;
                    }
                    _reminders.sort((a, b) {
                      final DateTime aDateTime = DateTime(
                          a['date'].year,
                          a['date'].month,
                          a['date'].day,
                          a['time'].hour,
                          a['time'].minute);
                      final DateTime bDateTime = DateTime(
                          b['date'].year,
                          b['date'].month,
                          b['date'].day,
                          b['time'].hour,
                          b['time'].minute);
                      return aDateTime.compareTo(bDateTime);
                    });
                  });

                  _scheduleNotification(newReminder);

                  Navigator.pop(context);
                }
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDetails(Map<String, dynamic> reminder, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          reminder['name'],
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'メモ: ${reminder['memo']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'URL: ${reminder['url']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                '日付: ${DateFormat('yyyy/MM/dd').format(reminder['date'])}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                '時刻: ${reminder['time'].format(context)}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                '繰り返し: ${reminder['repeat']}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                '優先順位: ${reminder['priority']}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _reminders.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text(
              '削除',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddReminderDialog(reminder: reminder, index: index);
            },
            child: Text(
              '編集',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '閉じる',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '高':
        return Colors.red;
      case '中':
        return Colors.yellow;
      case '低':
      default:
        return Colors.green;
    }
  }
}
