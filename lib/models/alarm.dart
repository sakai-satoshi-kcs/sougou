import 'package:flutter/material.dart';

class Alarm {
  String name;
  TimeOfDay time;
  List<bool> repeatDays;
  String sound;
  bool isEnabled;

  Alarm({
    required this.name,
    required this.time,
    required this.repeatDays,
    required this.sound,
    required this.isEnabled,
  });

  // JSON への変換（データの保存用）
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hour': time.hour,
      'minute': time.minute,
      'repeatDays': repeatDays,
      'sound': sound,
      'isEnabled': isEnabled,
    };
  }

  // JSON からの変換（データの読み込み用）
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      name: json['name'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      repeatDays: List<bool>.from(json['repeatDays']),
      sound: json['sound'],
      isEnabled: json['isEnabled'],
    );
  }
}
