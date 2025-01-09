class Task {
  final int id;
  final String name;
  final bool isCompleted;
  final String time;

  const Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.time = '0',
  });

  Task copyWith({
    int? id,
    String? name,
    bool? isCompleted,
    String? time,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      time: time ?? this.time,
    );
  }
}
