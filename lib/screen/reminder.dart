import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<Reminder> _reminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('リマインダー')),
      body: _reminders.isEmpty
          ? const Center(child: Text('リマインダーがありません'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return GestureDetector(
                  onTap: () => _showReminderDetails(reminder, index),
                  child: Card(
                    color:
                        _getPriorityColor(reminder.priority).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        reminder.name,
                        style: const TextStyle(
                          fontSize: 24, // タイトルのフォントサイズ
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // 中央揃え
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // 中央揃え
                        children: [
                          Text(
                            '日付: ${DateFormat('yyyy/MM/dd').format(reminder.date)}',
                            style:
                                const TextStyle(fontSize: 20), // サブタイトルのフォントサイズ
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '時刻: ${reminder.time.format(context)}',
                            style:
                                const TextStyle(fontSize: 20), // サブタイトルのフォントサイズ
                            textAlign: TextAlign.center,
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
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddReminderDialog({Reminder? reminder, int? index}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: reminder?.name ?? '');
    final memoController = TextEditingController(text: reminder?.memo ?? '');
    final urlController = TextEditingController(text: reminder?.url ?? '');
    DateTime? selectedDate = reminder?.date;
    TimeOfDay? selectedTime = reminder?.time;
    String repeat = reminder?.repeat ?? 'なし';
    String priority = reminder?.priority ?? '低';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(reminder == null ? 'リマインダーを追加' : 'リマインダーを編集'),
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
                  TextFormField(
                    controller: memoController,
                    decoration: const InputDecoration(labelText: 'メモ'),
                  ),
                  TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: 'URL'),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(selectedDate == null
                        ? '日付を選択'
                        : DateFormat('yyyy/MM/dd').format(selectedDate!)),
                    trailing: const Icon(Icons.calendar_today),
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
                    trailing: const Icon(Icons.access_time),
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
                    decoration: const InputDecoration(labelText: '繰り返し'),
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
                    decoration: const InputDecoration(labelText: '優先順位'),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate() &&
                    selectedDate != null &&
                    selectedTime != null) {
                  final newReminder = Reminder(
                    name: nameController.text,
                    memo: memoController.text,
                    url: urlController.text,
                    date: selectedDate!,
                    time: selectedTime!,
                    repeat: repeat,
                    priority: priority,
                  );

                  setState(() {
                    if (index == null) {
                      _reminders.add(newReminder);
                    } else {
                      _reminders[index] = newReminder;
                    }
                    _reminders.sort((a, b) {
                      final aDateTime = DateTime(a.date.year, a.date.month,
                          a.date.day, a.time.hour, a.time.minute);
                      final bDateTime = DateTime(b.date.year, b.date.month,
                          b.date.day, b.time.hour, b.time.minute);
                      return aDateTime.compareTo(bDateTime);
                    });
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

  void _showReminderDetails(Reminder reminder, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          reminder.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('メモ: ${reminder.memo ?? 'なし'}'),
              Text('URL: ${reminder.url ?? 'なし'}'),
              Text('日付: ${DateFormat('yyyy/MM/dd').format(reminder.date)}'),
              Text('時刻: ${reminder.time.format(context)}'),
              Text('繰り返し: ${reminder.repeat}'),
              Text('優先順位: ${reminder.priority}'),
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
            child: const Text('削除'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddReminderDialog(reminder: reminder, index: index);
            },
            child: const Text('編集'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
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
