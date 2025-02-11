import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screen/alarm.dart' as alarm_screen;
import 'screen/calendar.dart' as calendar_screen;
import 'screen/mainscreen.dart' as main_screen;
import 'screen/reminder.dart' as reminder_screen;
import 'screen/timetable.dart' as timetable_screen;

void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // ✅ ダークテーマ背景色
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // ✅ ヘッダーを黒に
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // ✅ ナビゲーションバーの背景を黒に
          selectedItemColor: Colors.blueAccent, // ✅ 選択時の色
          unselectedItemColor: Colors.grey, // ✅ 未選択時の色
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurpleAccent, // ✅ フローティングボタンの色
        ),
      ),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    alarm_screen.AlarmScreen(),
    calendar_screen.CalendarScreen(),
    main_screen.MainScreen(),
    reminder_screen.ReminderScreen(),
    timetable_screen.TimetableScreen(),
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
        backgroundColor: Colors.black, // ✅ ナビゲーションバーの背景を黒に統一
        selectedItemColor: Colors.blueAccent, // ✅ 選択時の色を青に
        unselectedItemColor: const Color.fromARGB(62, 158, 158, 158), // ✅ 未選択時の色をグレーに
        iconSize: 20, 
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          // TODO: 追加機能を実装
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}