import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用
import 'timetablecon.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final List<List<String?>> timetable = List.generate(5, (_) => List.filled(4, null)); // 月曜〜金曜, 4時間分
  final List<String> weekdays = ['月', '火', '水', '木', '金']; // 曜日リスト

  List<Map<String, String>> templates = []; // 管理画面から受け取る教科テンプレート

  int currentWeekdayIndex = DateTime.now().weekday - 1; // 今日の曜日インデックス（月曜が0）
  List<Map<String, dynamic>> todayTimetable = []; // 今日の時間割

  @override
  void initState() {
    super.initState();
    _resetTimetableOnSaturday();
    _updateTodayTimetable();
  }

  // 毎週土曜日に時間割をリセットする
  void _resetTimetableOnSaturday() {
    final now = DateTime.now();
    final nextSaturday = now.weekday == DateTime.saturday
        ? now
        : now.add(Duration(days: DateTime.saturday - now.weekday));
    final duration = nextSaturday.difference(now);
    Future.delayed(duration, () {
      setState(() {
        for (var row in timetable) {
          row.fillRange(0, row.length, null);
        }
        _updateTodayTimetable();
      });
      _resetTimetableOnSaturday(); // 次の土曜日のリセット予約
    });
  }

  // 今日の時間割を更新
  void _updateTodayTimetable() {
    if (currentWeekdayIndex >= 0 && currentWeekdayIndex < 5) {
      todayTimetable = List.generate(4, (period) {
        return {
          'period': '${period + 1}限', // 一限、二限、三限、四限
          'subject': timetable[currentWeekdayIndex][period],
        };
      }).where((item) => item['subject'] != null).toList();
    } else {
      todayTimetable = [];
    }
  }

  void _addSubject(int day, int period) async {
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テンプレートがありません。管理画面で作成してください。')),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return ListTile(
              title: Text(template['subject']!),
              subtitle: Text(template['room']!),
              onTap: () {
                Navigator.pop(context, template);
              },
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        timetable[day][period] = '${result["subject"]} (${result["room"]})';
        if (day == currentWeekdayIndex) {
          _updateTodayTimetable(); // 今日の曜日の時間割も更新
        }
      });
    }
  }

  void _openManagementScreen() async {
    final result = await Navigator.push<List<Map<String, String>>>(
      context,
      MaterialPageRoute(
        builder: (context) => const TimetableConScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        templates = result; // テンプレートを更新
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now(); // 現在の日付
    final formattedDate = DateFormat('yyyy/MM/dd').format(today); // 日付をフォーマット

    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openManagementScreen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // グリッド（曜日＋時間割）
            Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                // 曜日の行
                TableRow(
                  children: weekdays
                      .map((day) => Container(
                            height: 40,
                            alignment: Alignment.center,
                            color: const Color.fromARGB(130, 78, 206, 235),
                            child: Text(
                              day,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                ),
                // 時間割グリッド
                for (int period = 0; period < 4; period++)
                  TableRow(
                    children: [
                      for (int day = 0; day < 5; day++)
                        GestureDetector(
                          onTap: () => _addSubject(day, period),
                          child: Container(
                            height: 80,
                            alignment: Alignment.center,
                            child: Text(
                              timetable[day][period] ?? '未設定',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 1, color: Colors.grey),
            // 今日の時間割
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '今日の時間割',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$formattedDate　${weekdays[currentWeekdayIndex]}', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ...todayTimetable.map((entry) {
                    return Text(
                      '${entry["period"]}: ${entry["subject"]}',
                      textAlign: TextAlign.center,
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}