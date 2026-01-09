import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.isCompleted,
    required super.userId,
    required super.createdAt,
    super.startDate,
    super.endDate,
    super.position,
    super.priority,
    super.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      position: json['position'] ?? 0,
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'position': position,
      'priority': priorityToDbString(priority),
      'status': statusToDbString(status),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    int? position,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      position: position ?? this.position,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  static TaskPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  static String statusToDbString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
      case TaskStatus.todo:
        return 'todo';
    }
  }

  static String priorityToDbString(TaskPriority priority) {
    return priority.name; // 'low', 'medium', 'high' matches
  }
}
