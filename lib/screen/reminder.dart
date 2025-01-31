import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alarm.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  AlarmScreenState createState() => AlarmScreenState();
}

class AlarmScreenState extends State<AlarmScreen> {
  final List<Alarm> _alarms = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
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

  void _setAlarmNotification(Alarm alarm, int id) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledTime.isBefore(DateTime.now())) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      sound: RawResourceAndroidNotificationSound(alarm.sound), // 🔔 アラーム音
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      alarm.name,
      '目覚ましアラームが鳴ります！',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アラーム')),
      body: _alarms.isEmpty
          ? const Center(child: Text('アラームがありません'))
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      alarm.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '時刻: ${alarm.time.format(context)}\n'
                      '繰り返し: ${_formatRepeatDays(alarm.repeatDays)}\n'
                      'サウンド: ${alarm.sound}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    value: alarm.isEnabled,
                    onChanged: (value) {
                      setState(() {
                        alarm.isEnabled = value;
                      });
                      if (value) {
                        _setAlarmNotification(alarm, index);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlarmDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAlarmDialog({Alarm? alarm, int? index}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: alarm?.name ?? '');
    TimeOfDay? selectedTime = alarm?.time ?? TimeOfDay.now();
    List<bool> repeatDays = alarm?.repeatDays ?? List.filled(7, false);
    String selectedSound = alarm?.sound ?? 'default_alarm';
    bool isEnabled = alarm?.isEnabled ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(alarm == null ? 'アラームを追加' : 'アラームを編集'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '名前'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '名前を入力してください';
                      }
                      return null;
                    },
                  ),
                  ListTile(
                    title: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                  const Text('繰り返し設定'),
                  Wrap(
                    children: List.generate(7, (index) {
                      const days = ['月', '火', '水', '木', '金', '土', '日'];
                      return ChoiceChip(
                        label: Text(days[index]),
                        selected: repeatDays[index],
                        onSelected: (selected) {
                          setStateDialog(() {
                            repeatDays[index] = selected;
                          });
                        },
                      );
                    }),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedSound,
                    decoration: const InputDecoration(labelText: 'アラーム音'),
                    items: ['default_alarm', 'morning_birds', 'loud_bell']
                        .map((sound) =>
                            DropdownMenuItem(value: sound, child: Text(sound)))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedSound = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル')),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newAlarm = Alarm(
                    name: nameController.text,
                    time: selectedTime!,
                    repeatDays: repeatDays,
                    sound: selectedSound,
                    isEnabled: isEnabled,
                  );
                  setState(() {
                    if (index == null) {
                      _alarms.add(newAlarm);
                    } else {
                      _alarms[index] = newAlarm;
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRepeatDays(List<bool> repeatDays) {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    List<String> activeDays = [];
    for (int i = 0; i < repeatDays.length; i++) {
      if (repeatDays[i]) activeDays.add(days[i]);
    }
    return activeDays.isEmpty ? 'なし' : activeDays.join(', ');
  }
}
