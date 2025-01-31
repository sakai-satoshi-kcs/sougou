class Alarm {
  String name;
  TimeOfDay time;
  List<bool> repeatDays; // [月, 火, 水, 木, 金, 土, 日]
  String sound; // アラーム音のファイル名
  bool isEnabled;

  Alarm({
    required this.name,
    required this.time,
    required this.repeatDays,
    required this.sound,
    required this.isEnabled,
  });
}
