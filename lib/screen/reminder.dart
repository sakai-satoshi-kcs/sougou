import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [];

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
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '日付: ${reminder['date'] != null ? DateFormat('yyyy/MM/dd').format(reminder['date']) : '未設定'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '時刻: ${reminder['time'] != null ? reminder['time'].format(context) : '未設定'}',
                            style: const TextStyle(fontSize: 16),
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
                    decoration: const InputDecoration(labelText: '名前'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '名前を入力してください';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _memoController,
                    decoration: const InputDecoration(labelText: 'メモ'),
                  ),
                  TextFormField(
                    controller: _urlController,
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // 日付や時刻が未選択でも保存できるよう変更
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

                    // 日付と時刻が両方設定されているものは優先的にソート
                    // 未設定の場合は日付・時刻の順序を最後に回すようにする（任意）
                    _reminders.sort((a, b) {
                      final aDate = a['date'];
                      final aTime = a['time'];
                      final bDate = b['date'];
                      final bTime = b['time'];

                      // 両方とも日付・時刻がnullなら常に同一とみなす
                      if (aDate == null && aTime == null && bDate == null && bTime == null) {
                        return 0;
                      }

                      // aがnullでbがnullでない場合、aを後ろへ
                      if (aDate == null && aTime == null) {
                        return 1;
                      }

                      // bがnullでaがnullでない場合、bを後ろへ
                      if (bDate == null && bTime == null) {
                        return -1;
                      }

                      // どちらか片方がnullの場合、nullの方を後ろへ
                      if (aDate == null && bDate != null) return 1;
                      if (bDate == null && aDate != null) return -1;
                      if (aTime == null && bTime != null) return 1;
                      if (bTime == null && aTime != null) return -1;

                      // 両方とも日付と時刻がある場合は日時で比較
                      final DateTime aDateTime = DateTime(
                        aDate!.year, aDate.month, aDate.day,
                        aTime!.hour, aTime.minute);
                      final DateTime bDateTime = DateTime(
                        bDate!.year, bDate.month, bDate.day,
                        bTime!.hour, bTime.minute);
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

  void _showReminderDetails(Map<String, dynamic> reminder, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          reminder['name'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'メモ: ${reminder['memo']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'URL: ${reminder['url']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '日付: ${reminder['date'] != null ? DateFormat('yyyy/MM/dd').format(reminder['date']) : '未設定'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '時刻: ${reminder['time'] != null ? reminder['time'].format(context) : '未設定'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '繰り返し: ${reminder['repeat']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '優先順位: ${reminder['priority']}',
                style: const TextStyle(fontSize: 18),
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
            child: const Text(
              '削除',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddReminderDialog(reminder: reminder, index: index);
            },
            child: const Text(
              '編集',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
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