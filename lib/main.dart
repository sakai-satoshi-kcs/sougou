import 'package:flutter/material.dart';
import 'screen/alarm.dart';
import 'screen/calendar.dart';
import 'screen/mainscreen.dart';
import 'screen/reminder.dart';
import 'screen/timetable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    AlarmScreen(),
    CalendarScreen(),
    MainScreen(),
    ReminderScreen(),
    TimetableScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _screens[_selectedIndex],
    bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'アラーム'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'カレンダー'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'メイン'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'リマインダー'),
        BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: '時間割'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // ナビゲーションバーの背景色
      selectedItemColor: Colors.white, // 選択されたアイテムの色
      unselectedItemColor: Colors.grey, // 未選択アイテムの色
      showUnselectedLabels: true, // 未選択アイテムのラベルを表示する
    ),
  );
}

}
