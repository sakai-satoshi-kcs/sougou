import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
<<<<<<< HEAD
import 'models/alarm.dart';
import 'models/reminder.dart';
import 'screen/alarm.dart' as alarm_screen; // ← 別名をつける
import 'screen/calendar.dart';
import 'screen/mainscreen.dart';
import 'screen/reminder.dart' as reminder_screen; // ← 別名をつける
=======

import 'screen/alarm.dart' as alarm_screen;
import 'screen/calendar.dart';
import 'screen/mainscreen.dart';
import 'screen/reminder.dart' as reminder_screen;  // エイリアスの使用
>>>>>>> 73f9179098568c41ae105b27c3cd6099c0f0a9fe
import 'screen/timetable.dart';

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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
<<<<<<< HEAD
=======
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
>>>>>>> 73f9179098568c41ae105b27c3cd6099c0f0a9fe
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
  int _selectedIndex = 2;

  final List<Widget> _screens = [
<<<<<<< HEAD
    const alarm_screen.AlarmScreen(), // ← 明示的にする
    const CalendarScreen(),
    const MainScreen(),
    const reminder_screen.ReminderScreen(), // ← 明示的にする
=======
    alarm_screen.AlarmScreen(),
    const CalendarScreen(),  // const 修正
    const MainScreen(),
    reminder_screen.ReminderScreen(),  // エイリアスを使って解決
>>>>>>> 73f9179098568c41ae105b27c3cd6099c0f0a9fe
    const TimetableScreen(),
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
<<<<<<< HEAD
=======
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white60,
        showUnselectedLabels: true,
>>>>>>> 73f9179098568c41ae105b27c3cd6099c0f0a9fe
      ),
    );
  }
}