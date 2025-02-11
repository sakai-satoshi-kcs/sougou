import 'package:flutter/material.dart';
import '../models/reminder.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  ReminderScreenState createState() => ReminderScreenState();
}

class ReminderScreenState extends State<ReminderScreen> {
  final List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
  }

  void _addReminder() {
    final now = DateTime.now();
    final newReminder = Reminder(
      name: "新しいリマインダー",
      date: now,
      time: TimeOfDay(hour: now.hour, minute: now.minute),
      repeat: "なし",
      priority: "普通",
    );

    setState(() {
      _reminders.add(newReminder);
    });
  }

  void _removeReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
  }

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
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      reminder.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '日時: ${DateFormat('yyyy/MM/dd HH:mm').format(reminder.date)}\n'
                      '繰り返し: ${reminder.repeat}\n'
                      '優先度: ${reminder.priority}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeReminder(index),
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
    DateTime selectedDate = reminder?.date ?? DateTime.now();
    TimeOfDay selectedTime = reminder?.time ?? TimeOfDay.now();
    String selectedRepeat = reminder?.repeat ?? 'なし';
    String selectedPriority = reminder?.priority ?? '普通';

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
                  ListTile(
                    title: Text(DateFormat('yyyy/MM/dd').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
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
                  DropdownButtonFormField<String>(
                    value: selectedRepeat,
                    decoration: const InputDecoration(labelText: '繰り返し'),
                    items: ['なし', '毎日', '毎週', '毎月']
                        .map((repeat) => DropdownMenuItem(
                              value: repeat,
                              child: Text(repeat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedRepeat = value!;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: const InputDecoration(labelText: '優先度'),
                    items: ['低', '普通', '高']
                        .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedPriority = value!;
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
                  setState(() {
                    final newReminder = Reminder(
                      name: nameController.text,
                      date: selectedDate,
                      time: selectedTime,
                      repeat: selectedRepeat,
                      priority: selectedPriority,
                    );

                    if (index == null) {
                      _reminders.add(newReminder);
                    } else {
                      _reminders[index] = newReminder;
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
}