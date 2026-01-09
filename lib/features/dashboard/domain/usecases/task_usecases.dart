import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}

class UpdateTaskPositionUseCase implements UseCase<void, UpdateTaskPositionParams> {
    final TaskRepository repository;

  UpdateTaskPositionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTaskPositionParams params) async {
    return await repository.updateTaskPositions(params.tasks);
  }
}

class UpdateTaskPositionParams extends Equatable {
  final List<TaskEntity> tasks;

  const UpdateTaskPositionParams(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class AddTaskUseCase implements UseCase<TaskEntity, AddTaskParams> {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(AddTaskParams params) async {
    return await repository.addTask(
      title: params.title,
      description: params.description,
      startDate: params.startDate,
      endDate: params.endDate,
      priority: params.priority,
    );
  }
}

class AddTaskParams extends Equatable {
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final TaskPriority priority;

  const AddTaskParams({
    required this.title,
    this.description = '',
    this.startDate,
    this.endDate,
    this.priority = TaskPriority.medium,
  });

  @override
  List<Object?> get props => [title, description, startDate, endDate, priority];
}

class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(params.id);
  }
}

class DeleteTaskParams extends Equatable {
  final String id;

  const DeleteTaskParams(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateTaskUseCase implements UseCase<TaskEntity, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async {
    return await repository.updateTask(params.task);
  }
}

class UpdateTaskParams extends Equatable {
  final TaskEntity task;

  const UpdateTaskParams(this.task);

  @override
  List<Object> get props => [task];
}
