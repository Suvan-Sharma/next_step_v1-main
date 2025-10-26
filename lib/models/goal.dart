class Goal {
  String title;
  String? description;
  String category;
  String priority;
  String frequency; // Today / Weekly / Monthly
  String? time; // Optional display time like "9.00 AM"
  bool reminder;
  bool isCompleted;

  Goal({
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.frequency,
    this.time,
    this.reminder = false,
    this.isCompleted = false,
  });

  // Serialize to a JSON-serializable Map
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'frequency': frequency,
        'time': time,
        'reminder': reminder,
        'isCompleted': isCompleted,
      };

  // Deserialize from a Map
  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        category: (json['category'] as String?) ?? 'General',
        priority: (json['priority'] as String?) ?? 'Normal',
        frequency: (json['frequency'] as String?) ?? 'Today',
        time: json['time'] as String?,
        reminder: (json['reminder'] as bool?) ?? false,
        isCompleted: (json['isCompleted'] as bool?) ?? false,
      );
}
