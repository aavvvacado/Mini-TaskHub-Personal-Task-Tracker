import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final remoteTasks = await remoteDataSource.getTasks();
      return Right(remoteTasks.cast<TaskEntity>());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask({
    required String title,
    String description = '',
    DateTime? startDate,
    DateTime? endDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    try {
      final task = await remoteDataSource.addTask(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        priority: priority,
      );
      return Right(task as TaskEntity);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskPositions(
    List<TaskEntity> tasks,
  ) async {
    try {
      // Cast entities back to models (or create utility)
      final taskModels = tasks
          .map(
            (e) => TaskModel(
              id: e.id,
              title: e.title,
              description: e.description,
              isCompleted: e.isCompleted,
              userId: e.userId,
              createdAt: e.createdAt,
              startDate: e.startDate,
              endDate: e.endDate,
              position: e.position,
              priority: e.priority,
              status: e.status,
            ),
          )
          .toList();

      await remoteDataSource.updateTaskPositions(taskModels);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final updatedTask = await remoteDataSource.updateTask(task);
      return Right(updatedTask as TaskEntity);
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
