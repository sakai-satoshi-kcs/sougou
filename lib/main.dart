import 'package:flutter/material.dart';
import 'screen/alarm.dart';
import 'screen/calendar.dart';
import 'screen/mainscreen.dart';
import 'screen/reminder.dart';
import 'screen/timetable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        brightness: Brightness.dark, // ダークモード
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18), // 背景色
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E), // アプリバーの背景色
          foregroundColor: Colors.white, // アプリバーの文字色
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // bodyText1 の代替
          bodyMedium: TextStyle(color: Colors.white70), // bodyText2 の代替
        ),
      ),
      home: const MainApp(),
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

  // 修正: const を削除
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
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white60,
        showUnselectedLabels: true,
      ),
    );
  }
}
