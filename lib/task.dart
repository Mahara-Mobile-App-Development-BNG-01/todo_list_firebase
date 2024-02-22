
class Task {
  final String title;
  final bool completed;

  Task({required this.title, required this.completed});

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    completed: json['completed'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          completed == other.completed;

  @override
  int get hashCode => title.hashCode ^ completed.hashCode;
}