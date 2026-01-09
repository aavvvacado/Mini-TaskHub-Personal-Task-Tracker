import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted; // Deprecated, mapped to status
  final String userId;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final int position;
  final TaskPriority priority;
  final TaskStatus status;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.position = 0,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        userId,
        createdAt,
        startDate,
        endDate,
        position,
        priority,
        status,
      ];
}
