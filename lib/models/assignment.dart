enum Priority { high, medium, low }

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.high => 'High',
        Priority.medium => 'Medium',
        Priority.low => 'Low',
      };
  static Priority fromString(String s) => switch (s.toLowerCase()) {
        'high' => Priority.high,
        'medium' => Priority.medium,
        'low' => Priority.low,
        _ => Priority.medium,
      };
}

enum AssignmentStatus { pending, inProgress, completed }

extension AssignmentStatusX on AssignmentStatus {
  String get label => switch (this) {
        AssignmentStatus.pending => 'Pending',
        AssignmentStatus.inProgress => 'In Progress',
        AssignmentStatus.completed => 'Completed',
      };
  static AssignmentStatus fromString(String s) => switch (s) {
        'Pending' => AssignmentStatus.pending,
        'In Progress' => AssignmentStatus.inProgress,
        'Completed' => AssignmentStatus.completed,
        _ => AssignmentStatus.pending,
      };
}

class Assignment {
  final String id;
  final String courseId;
  String title;
  String notes;
  DateTime dueDate;
  Priority priority;
  AssignmentStatus status;
  int progress; // 0..100
  String reminder; // e.g. "1 day before"

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.dueDate,
    this.notes = '',
    this.priority = Priority.medium,
    this.status = AssignmentStatus.pending,
    this.progress = 0,
    this.reminder = '1 day before',
  });

  bool get isOverdue =>
      status != AssignmentStatus.completed &&
      dueDate.isBefore(DateTime.now());

  bool get isUrgent {
    if (status == AssignmentStatus.completed) return false;
    final hoursLeft = dueDate.difference(DateTime.now()).inHours;
    return hoursLeft >= 0 && hoursLeft <= 48;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'notes': notes,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.label,
        'status': status.label,
        'progress': progress,
        'reminder': reminder,
      };

  factory Assignment.fromJson(Map<String, dynamic> j) => Assignment(
        id: j['id'] as String,
        courseId: j['courseId'] as String,
        title: j['title'] as String,
        notes: (j['notes'] ?? '') as String,
        dueDate: DateTime.parse(j['dueDate'] as String),
        priority: PriorityX.fromString((j['priority'] ?? 'Medium') as String),
        status: AssignmentStatusX.fromString(
            (j['status'] ?? 'Pending') as String),
        progress: (j['progress'] ?? 0) as int,
        reminder: (j['reminder'] ?? '1 day before') as String,
      );
}
