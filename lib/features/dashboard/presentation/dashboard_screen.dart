import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../features/settings/presentation/settings_screen.dart';
import '../../../../core/presentation/widgets/onboarding_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart' as auth_state;
import '../domain/entities/task_entity.dart';
import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'bloc/task_state.dart';
import 'widgets/add_edit_task_dialog.dart';
import 'widgets/task_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<TaskBloc>()..add(LoadTasks())),
        BlocProvider(create: (context) => sl<AuthBloc>()),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  
  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_tutorial') ?? false;
    if (!seen && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const OnboardingDialog(),
      );
      await prefs.setBool('seen_tutorial', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocListener<AuthBloc, auth_state.AuthState>(
        listener: (context, state) {
          if (state is auth_state.AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else if (state is auth_state.AuthError) {
             UIUtils.showSnackBar(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Mini TaskHub'),
            bottom: const TabBar(
               indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Todo'),
                Tab(text: 'On It'), // More fun name
                Tab(text: 'Done'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                   // Capture the existing AuthBloc instance
                   final authBloc = context.read<AuthBloc>();
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => BlocProvider.value(
                         value: authBloc, // Pass it to the new route
                         child: const SettingsScreen(),
                       ),
                     ),
                   );
                },
              ),
            ],
          ),
          body: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                 return _buildShimmerLoading();
              } else if (state is TaskLoaded) {
                // Filter tasks for each tab
                final todoTasks = state.tasks.where((t) => t.status == TaskStatus.todo).toList();
                final inProgressTasks = state.tasks.where((t) => t.status == TaskStatus.inProgress).toList();
                final doneTasks = state.tasks.where((t) => t.status == TaskStatus.done).toList();

                return TabBarView(
                  children: [
                    _buildTaskList(todoTasks, 'No Tasks to do! Relax 🌴'),
                    _buildTaskList(inProgressTasks, 'Nothing in progress. Get to work! 🚀'),
                    _buildTaskList(doneTasks, 'No finished tasks yet.', canDelete: true),
                  ],
                );
              } else if (state is TaskError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   UIUtils.showSnackBar(context, state.message, isError: true);
                });
                return const SizedBox.shrink(); 
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
               showDialog(
                 context: context,
                 builder: (_) => BlocProvider.value(
                   value: context.read<TaskBloc>(), // Pass existing Bloc
                   child: const AddEditTaskDialog(),
                 ),
               );
            },
            label: const Text('Add Task'),
            icon: const Icon(Icons.add_task), // Better icon
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<TaskBloc>().add(LoadTasks());
    // Wait for state to change or just delay slightly for UX
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget _buildTaskList(List<TaskEntity> tasks, String emptyMsg, {bool canDelete = false}) {
    if (tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 60, color: Colors.grey[300]),
                  const Gap(16),
                  Text(emptyMsg, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ).animate().fadeIn(),
            ),
          ),
        ),
      );
    }
    
    // We must pass a key to ReorderableListView to maintain state
    // Using a simple RefershIndicator wrapping it.
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
            final task = tasks[index];
            // Key is crucial for reordering
            return Container(
              key: Key(task.id),
              child: TaskTile(task: task),
            );
        },
        onReorder: (oldIndex, newIndex) {
            // Reorder logic
             if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            
            // Create a modified list specific to this view
            final reorderedList = List<TaskEntity>.from(tasks);
            final item = reorderedList.removeAt(oldIndex);
            reorderedList.insert(newIndex, item);

            // Now we need to update positions.
            // Strategy: We assign position values based on the *sort order* we just created.
            // To be robust, we can just assign indexes 0, 1, 2... or check existing positions.
            // But 'tasks' passed here is a subset (e.g. only Todos).
            // So we should take the range of positions that these tasks *occupy* and redistribute them?
            // Or easier: Just assign descending or ascending values. 
            // Our query sorts by position ascending.
            // So let's assign 0, 1, 2... relative to this list?
            // Warning: If we have multiple lists, this might overlap.
            // Better: Keep the *set of position values* currently used by these tasks, sort them, and redistribute?
            // E.g. existing positions: 5, 8, 12.
            // We just swapped items. New order should get positions 5, 8, 12.
            
            // Collection of current positions
            final existingPositions = tasks.map((e) => e.position).toList()..sort();
            
            final updates = <TaskEntity>[];
            for(int i=0; i<reorderedList.length; i++) {
                // If existingPositions is valid and has enough items, use it.
                // Else use index.
                int newPos = i < existingPositions.length ? existingPositions[i] : i;
                
                // If we want to strictly enforce order 0..N for this list:
                // This might clash if we move items between lists (Todo->Done).
                // But for reordering *within* a list, using the existing pool of positions is safest to avoid collisions with other lists.
                // Fallback: If existing positions are all 0 (default), we need to generate new ones.
                if (existingPositions.every((p) => p == 0)) {
                   newPos = i;
                }
                
                final updatedTask = TaskEntity(
                  id: reorderedList[i].id,
                  title: reorderedList[i].title,
                  description: reorderedList[i].description,
                  isCompleted: reorderedList[i].isCompleted,
                  status: reorderedList[i].status,
                  userId: reorderedList[i].userId,
                  createdAt: reorderedList[i].createdAt,
                  startDate: reorderedList[i].startDate,
                  endDate: reorderedList[i].endDate,
                  position: newPos,
                  priority: reorderedList[i].priority
                );
                updates.add(updatedTask);
            }
            
            context.read<TaskBloc>().add(UpdateTaskOrder(updates));
        },
        proxyDecorator: (child, index, animation) {
           return AnimatedBuilder(
             animation: animation,
             builder: (BuildContext context, Widget? child) {
               return Material(
                 elevation: 8,
                 color: Colors.transparent,
                 shadowColor: Colors.black26, 
                 borderRadius: BorderRadius.circular(16),
                 child: child,
               );
             },
             child: child,
           );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100, // Match typical card height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
