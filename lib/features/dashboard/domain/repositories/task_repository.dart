import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> addTask({
    required String title,
    String description = '',
    DateTime? startDate,
    DateTime? endDate,
    TaskPriority priority = TaskPriority.medium,
  });
  Future<Either<Failure, void>> updateTaskPositions(List<TaskEntity> tasks);
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
}
