import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> addTask({
    required String title,
    required String description,
    required DateTime? startDate,
    required DateTime? endDate,
    required TaskPriority priority,
  });
  Future<void> updateTaskPositions(List<TaskModel> tasks);
  Future<void> deleteTask(String id);
  Future<TaskModel> updateTask(TaskEntity task);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final SupabaseClient supabaseClient;

  TaskRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await supabaseClient
          .from('tasks')
          .select()
          .order(
            'position',
            ascending: true,
          ) // Tasks with lower position # (e.g. 0) come first
          .order('created_at', ascending: false);

      return (response as List).map((e) => TaskModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskModel> addTask({
    required String title,
    required String description,
    required DateTime? startDate,
    required DateTime? endDate,
    required TaskPriority priority,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw const AuthFailure();

      final response = await supabaseClient
          .from('tasks')
          .insert({
            'title': title,
            'description': description,
            'user_id': user.id,
            'is_completed': false,
            'status': TaskModel.statusToDbString(TaskStatus.todo),
            'priority': TaskModel.priorityToDbString(priority),
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'position': 0, // Default to top or need to query max
          })
          .select()
          .single();

      return TaskModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateTaskPositions(List<TaskModel> tasks) async {
    try {
      // Batch update using upsert.
      // Note: Supabase upsert requires primary key match.
      final updates = tasks
          .map((t) => {'id': t.id, 'position': t.position})
          .toList();

      // Using simpler loop for now if batch has issues, but batch is preferred
      for (var update in updates) {
        await supabaseClient
            .from('tasks')
            .update({'position': update['position']})
            .eq('id', update['id']!);
      }
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await supabaseClient.from('tasks').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TaskModel> updateTask(TaskEntity task) async {
    try {
      final response = await supabaseClient
          .from('tasks')
          .update({
            'title': task.title,
            'description': task.description,
            'is_completed': task.isCompleted,
            'status': TaskModel.statusToDbString(task.status),
            'priority': TaskModel.priorityToDbString(task.priority),
            'start_date': task.startDate?.toIso8601String(),
            'end_date': task.endDate?.toIso8601String(),
            'position': task.position,
          })
          .eq('id', task.id)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
