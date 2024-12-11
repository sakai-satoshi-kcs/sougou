import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  bool allDay;
  DateTime startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool notify;
  String? url;
  String? memo;

  Event({
    required this.title,
    this.allDay = false,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.notify = false,
    this.url,
    this.memo,
  });
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _showAddEventDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController urlController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    bool allDay = false;
    DateTime? endDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool notify = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("予定を追加"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "タイトル"),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("終日"),
                        Switch(
                          value: allDay,
                          onChanged: (value) {
                            setState(() {
                              allDay = value;
                              if (!allDay) {
                                endDate = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (!allDay) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "開始時間: ${startTime?.format(context) ?? "未設定"}"),
                          TextButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  startTime = pickedTime;
                                });
                              }
                            },
                            child: Text("設定"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("終了時間: ${endTime?.format(context) ?? "未設定"}"),
                          TextButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  endTime = pickedTime;
                                });
                              }
                            },
                            child: Text("設定"),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("終了日: ${endDate != null ? "${endDate!.toLocal()}".split(' ')[0] : "未設定"}"),
                          TextButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDay!,
                                firstDate: _selectedDay!,
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  endDate = pickedDate;
                                });
                              }
                            },
                            child: Text("設定"),
                          ),
                        ],
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("通知"),
                        Switch(
                          value: notify,
                          onChanged: (value) {
                            setState(() {
                              notify = value;
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: urlController,
                      decoration: InputDecoration(labelText: "URL"),
                    ),
                    TextFormField(
                      controller: memoController,
                      decoration: InputDecoration(labelText: "メモ"),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("キャンセル"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        final event = Event(
                          title: titleController.text,
                          allDay: allDay,
                          startDate: _selectedDay!,
                          endDate: allDay ? endDate : null,
                          startTime: allDay ? null : startTime,
                          endTime: allDay ? null : endTime,
                          notify: notify,
                          url: urlController.text.isNotEmpty
                              ? urlController.text
                              : null,
                          memo: memoController.text.isNotEmpty
                              ? memoController.text
                              : null,
                        );

                        if (_events[_selectedDay!] == null) {
                          _events[_selectedDay!] = [];
                        }
                        _events[_selectedDay!]!.add(event);
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: Text("追加"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('カレンダー')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay!).map((event) {
                return ListTile(
                  title: Text(event.title),
                  subtitle: event.allDay
                      ? Text("終日イベント: ${event.startDate.toLocal()} 〜 ${event.endDate?.toLocal()}")
                      : Text(
                          "${event.startTime?.format(context)} - ${event.endTime?.format(context)}"),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
