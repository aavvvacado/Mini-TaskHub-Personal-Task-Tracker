import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final TaskPriority priority;

  const AddTask({
    required this.title,
    this.description = '',
    this.startDate,
    this.endDate,
    this.priority = TaskPriority.medium,
  });

  @override
  List<Object?> get props => [title, description, startDate, endDate, priority];
}

class UpdateTaskOrder extends TaskEvent {
  final List<TaskEntity> tasks;

  const UpdateTaskOrder(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class DeleteTask extends TaskEvent {
  final String id;

  const DeleteTask(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleTaskCompletion extends TaskEvent {
  final TaskEntity task;

  const ToggleTaskCompletion(this.task);

  @override
  List<Object> get props => [task];
}

class EditTask extends TaskEvent {
  final TaskEntity task;

  const EditTask(this.task);

  @override
  List<Object> get props => [task];
}
