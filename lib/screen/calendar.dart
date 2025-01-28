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
  Color color;

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
    this.color = Colors.blue,
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

  void _showEventDialog({Event? event, required DateTime selectedDay}) {
    final TextEditingController titleController = TextEditingController(
        text: event != null ? event.title : '');
    final TextEditingController urlController = TextEditingController(
        text: event != null ? event.url ?? '' : '');
    final TextEditingController memoController = TextEditingController(
        text: event != null ? event.memo ?? '' : '');
    bool allDay = event?.allDay ?? false;
    DateTime? endDate = event?.endDate;
    TimeOfDay? startTime = event?.startTime;
    TimeOfDay? endTime = event?.endTime;
    bool notify = event?.notify ?? false;
    Color selectedColor = event?.color ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(event == null ? "予定を追加" : "予定を編集"),
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
                                initialDate: selectedDay,
                                firstDate: selectedDay,
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
                    SizedBox(height: 8),
                    DropdownButton<Color>(
                      value: selectedColor,
                      onChanged: (color) {
                        setState(() {
                          selectedColor = color!;
                        });
                      },
                      items: [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                      ]
                          .map((color) => DropdownMenuItem(
                                value: color,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: color,
                                ),
                              ))
                          .toList(),
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
                        final newEvent = Event(
                          title: titleController.text,
                          allDay: allDay,
                          startDate: selectedDay,
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
                          color: selectedColor,
                        );

                        if (event == null) {
                          if (_events[selectedDay] == null) {
                            _events[selectedDay] = [];
                          }
                          _events[selectedDay]!.add(newEvent);
                        } else {
                          final index =
                              _events[selectedDay]!.indexOf(event);
                          if (index != -1) {
                            _events[selectedDay]![index] = newEvent;
                          }
                        }
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: Text(event == null ? "追加" : "保存"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEventDetails(Event event, DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.allDay)
                Text("終日イベント: ${event.startDate.toLocal()} ～ ${event.endDate?.toLocal()}"),
              if (!event.allDay)
                Text(
                    "時間: ${event.startTime?.format(context)} ～ ${event.endTime?.format(context)}"),
              if (event.url != null) Text("URL: ${event.url}"),
              if (event.memo != null) Text("メモ: ${event.memo}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEventDialog(event: event, selectedDay: selectedDay);
              },
              child: Text("編集"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("閉じる"),
            ),
          ],
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
            availableCalendarFormats: const {
              CalendarFormat.month: '月',
            },
          ),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay!).map((event) {
                return ListTile(
                  title: Text(event.title),
                  subtitle: event.allDay
                      ? Text(
                          "終日イベント: ${event.startDate.toLocal()} 〜 ${event.endDate?.toLocal()}")
                      : Text(
                          "${event.startTime?.format(context)} - ${event.endTime?.format(context)}"),
                  onTap: () => _showEventDetails(event, _selectedDay!),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(
          selectedDay: _selectedDay!,
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
