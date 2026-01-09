import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_usecases.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final UpdateTaskPositionUseCase updateTaskPositionUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.deleteTaskUseCase,
    required this.updateTaskUseCase,
    required this.updateTaskPositionUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<EditTask>(_onEditTask);
    on<UpdateTaskOrder>(_onUpdateTaskOrder);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTasksUseCase(NoParams());
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TaskLoaded(tasks)),
    );
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    // Keep loading state or use optimistic update? Simple loading for now.
    emit(TaskLoading()); 
    final result = await addTaskUseCase(AddTaskParams(
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      priority: event.priority,
    ));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (task) {
        add(LoadTasks()); // Reload to get sorted/fresh list
      },
    );
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final result = await deleteTaskUseCase(DeleteTaskParams(event.id));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => add(LoadTasks()),
    );
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    // Determine new status based on completion toggle
    final newIsCompleted = !event.task.isCompleted;
    final newStatus = newIsCompleted ? TaskStatus.done : TaskStatus.todo;

    final updatedTask = TaskEntity(
      id: event.task.id,
      title: event.task.title,
      description: event.task.description,
      isCompleted: newIsCompleted,
      status: newStatus,
      userId: event.task.userId,
      createdAt: event.task.createdAt,
      startDate: event.task.startDate,
      endDate: event.task.endDate,
      position: event.task.position,
      priority: event.task.priority,
    );
    final result = await updateTaskUseCase(UpdateTaskParams(updatedTask));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => add(LoadTasks()),
    );
  }

  Future<void> _onEditTask(EditTask event, Emitter<TaskState> emit) async {
     final result = await updateTaskUseCase(UpdateTaskParams(event.task));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => add(LoadTasks()),
    );
  }
  
  Future<void> _onUpdateTaskOrder(UpdateTaskOrder event, Emitter<TaskState> emit) async {
    // Optimistic update could happen here in UI, but for now we persist then reload (or just persist)
    // Actually for reorder, we usually want to update local state immediately. 
    // But since we rely on LoadTasks for sorting, let's persist then load.
    // Ideally: Emit(TaskLoaded(event.tasks)) immediately, then persist in background.
    
    if (state is TaskLoaded) {
       emit(TaskLoaded(event.tasks)); // Optimistic local update
    }

    final result = await updateTaskPositionUseCase(UpdateTaskPositionParams(event.tasks));
    result.fold(
      (failure) {
         // Revert on failure? For now just show error
         emit(TaskError(failure.message));
         add(LoadTasks()); // Re-fetch correct order
      },
      (_) {
        // Success - tasks already updated locally or we can do nothing.
      }
    );
  }
}
