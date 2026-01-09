import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' as intl;

import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'add_edit_task_dialog.dart';

class TaskTile extends StatelessWidget {
  final TaskEntity task;

  const TaskTile({super.key, required this.task});

  Color _getStatusColor(TaskStatus status, bool isMissed) {
    if (isMissed) return const Color(0xFFE57373); // Red/Coral
    switch (status) {
      case TaskStatus.done:
        return const Color(0xFF4DB6AC); // Teal
      case TaskStatus.inProgress:
        return const Color(0xFFEFA545); // Orange/Yellow
      case TaskStatus.todo:
        return const Color(0xFF4E93E6); // Blue
    }
  }

  void _showEditDialog(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: AddEditTaskDialog(task: task),
      ),
    );
  }

  Future<bool?> _confirmDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (task.status == TaskStatus.todo) {
      if (direction == DismissDirection.startToEnd) {
        _updateStatus(context, TaskStatus.inProgress);
        _showSnack(context, "Task Started! 🚀");
        return false;
      } else {
        _showSnack(context, "Task Deleted 🗑️");
        return true; // Delete
      }
    } else if (task.status == TaskStatus.inProgress) {
      if (direction == DismissDirection.startToEnd) {
        _updateStatus(context, TaskStatus.done);
        _showSnack(context, "Task Completed! 🎉");
        return false;
      } else {
        _showSnack(context, "Finish task to delete! 🚫");
        return false;
      }
    } else {
      if (direction == DismissDirection.endToStart) {
        _showSnack(context, "Task Deleted 🗑️");
        return true;
      }
    }
    return false;
  }

  void _updateStatus(BuildContext context, TaskStatus newStatus) {
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: newStatus == TaskStatus.done,
      status: newStatus,
      userId: task.userId,
      createdAt: task.createdAt,
      startDate: task.startDate,
      endDate: task.endDate,
      position: task.position,
      priority: task.priority,
    );
    context.read<TaskBloc>().add(EditTask(updated));
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = intl.DateFormat('MMM d');
    final isMissed =
        task.status != TaskStatus.done &&
        task.endDate != null &&
        task.endDate!.isBefore(DateTime.now());

    final statusColor = _getStatusColor(task.status, isMissed);

    // Subtle Tint for "Premium White" look
    // Blends 5% of status color into white surface
    final cardColor = Color.alphaBlend(
      statusColor.withOpacity(0.04),
      Colors.white,
    );

    double progress = 0;
    if (task.status == TaskStatus.done) progress = 1.0;
    if (task.status == TaskStatus.inProgress) progress = 0.5;

    return Dismissible(
      key: Key(task.id),
      direction: task.status == TaskStatus.inProgress
          ? DismissDirection.startToEnd
          : DismissDirection.horizontal,
      confirmDismiss: (direction) => _confirmDismiss(context, direction),
      onDismissed: (_) => context.read<TaskBloc>().add(DeleteTask(task.id)),
      background: _buildSwipeAction(
        Alignment.centerLeft,
        Colors.blue,
        Icons.play_arrow_rounded,
        "START",
      ),
      secondaryBackground: _buildSwipeAction(
        Alignment.centerRight,
        Colors.redAccent,
        Icons.delete_outline_rounded,
        "DELETE",
      ),

      child: GestureDetector(
        onTap: () => _showEditDialog(context, task),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.15), // Colored Shadow!
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 2,
            ), // White Ring effect
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled Icon Container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Rounded Square instead of circle
                  border: Border.all(
                    color: statusColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isMissed
                      ? Icons.warning_amber_rounded
                      : task.status == TaskStatus.done
                      ? Icons.check_circle_outline
                      : task.status == TaskStatus.inProgress
                      ? Icons.timelapse_rounded
                      : Icons.calendar_today_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const Gap(16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D3A), // Softer Black
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(6),
                    Text(
                      task.description.isNotEmpty
                          ? task.description
                          : "No additional details",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(12),

                    // Footer: Date & Priority
                    Row(
                      children: [
                        // Date Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                              const Gap(4),
                              Text(
                                _formatDateRange(dateFormat),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isMissed
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Gap(12),

              // Progress Ring
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: statusColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      task.status == TaskStatus.done
                          ? "100%"
                          : task.status == TaskStatus.inProgress
                          ? "50%"
                          : "0%",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
    );
  }

  String _formatDateRange(intl.DateFormat format) {
    if (task.startDate == null) return "No Date";
    final start = format.format(task.startDate!);
    if (task.endDate != null) {
      final end = format.format(task.endDate!);
      if (start == end) return start;
      return "$start - $end";
    }
    return start;
  }

  Widget _buildSwipeAction(
    Alignment align,
    Color color,
    IconData icon,
    String label,
  ) {
    var finalIcon = icon;
    var finalLabel = label;
    // Context-aware labels?
    // Passed in label is correct based on call site.

    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(finalIcon, color: Colors.white, size: 28),
          const Gap(8),
          Text(
            finalLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
