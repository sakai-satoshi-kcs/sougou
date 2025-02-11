class Event {
  final String title; // イベント名
  final DateTime startDate; // イベントの開始日時
  final DateTime? endDate; // イベントの終了日時 (オプション)
  final String? description; // 詳細情報 (オプション)

  Event({
    required this.title,
    required this.startDate,
    this.endDate,
    this.description,
  });

  // JSON 変換用
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? 'イベント',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
    };
  }
}