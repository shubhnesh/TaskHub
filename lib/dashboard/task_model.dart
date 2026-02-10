class Task {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['body'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      userId: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': title,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'uid': userId,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}