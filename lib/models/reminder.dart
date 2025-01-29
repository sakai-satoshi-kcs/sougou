import 'package:flutter/material.dart';

class Reminder {
  final String name;
  final String? memo;
  final String? url;
  final DateTime date;
  final TimeOfDay time;
  final String repeat;
  final String priority;

  Reminder({
    required this.name,
    this.memo,
    this.url,
    required this.date,
    required this.time,
    required this.repeat,
    required this.priority,
  });
}