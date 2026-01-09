import 'package:flutter_test/flutter_test.dart';
import 'package:task_trecker/features/dashboard/data/models/task_model.dart';
import 'package:task_trecker/features/dashboard/domain/entities/task_entity.dart';

void main() {
  final tTaskModelWithDate = TaskModel(
      id: '1',
      title: 'Test Task',
      description: 'Desc',
      isCompleted: false,
      userId: 'user1',
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      dueDate: DateTime.parse('2023-01-02T00:00:00.000Z'),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
  );

  test('should be a subclass of TaskEntity', () async {
    expect(tTaskModelWithDate, isA<TaskEntity>());
  });

  test('fromJson should return a valid model with new fields', () async {
    final Map<String, dynamic> jsonMap = {
      'id': '1',
      'title': 'Test Task',
      'description': 'Desc',
      'is_completed': false,
      'user_id': 'user1',
      'created_at': '2023-01-01T00:00:00.000Z',
      'due_date': '2023-01-02T00:00:00.000Z',
      'priority': 'high',
      'status': 'in_progress', // Matches _parseStatus logic
    };
    
    final result = TaskModel.fromJson(jsonMap);
    expect(result, tTaskModelWithDate);
  });

  test('toJson should return a JSON map containing proper data', () async {
    final result = tTaskModelWithDate.toJson();
    final expectedJson = {
      'title': 'Test Task',
      'description': 'Desc',
      'is_completed': false,
      'user_id': 'user1',
      'created_at': '2023-01-01T00:00:00.000Z',
      'due_date': '2023-01-02T00:00:00.000Z',
      'priority': 'high',
      'status': 'inProgress', // Enum.name default
    };
    expect(result, expectedJson);
  });
}
