import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' as intl;
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class AddEditTaskDialog extends StatefulWidget {
  final TaskEntity? task; // If null, it's Add mode

  const AddEditTaskDialog({super.key, this.task});

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTimeRange? _selectedDateRange;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    
    if (widget.task?.startDate != null && widget.task?.endDate != null) {
      _selectedDateRange = DateTimeRange(
        start: widget.task!.startDate!,
        end: widget.task!.endDate!,
      );
    }
    
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years
      initialDateRange: _selectedDateRange, 
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.task == null) {
        // Add Mode
        context.read<TaskBloc>().add(AddTask(
              title: _titleController.text,
              description: _descController.text,
              startDate: _selectedDateRange?.start,
              endDate: _selectedDateRange?.end,
              priority: _priority,
            ));
      } else {
        // Edit Mode
        final updatedTask = TaskEntity(
            id: widget.task!.id,
            title: _titleController.text,
            description: _descController.text,
            isCompleted: widget.task!.isCompleted, 
            status: widget.task!.status,
            userId: widget.task!.userId,
            createdAt: widget.task!.createdAt,
            startDate: _selectedDateRange?.start,
            endDate: _selectedDateRange?.end,
            position: widget.task!.position, 
            priority: _priority,
        );
        context.read<TaskBloc>().add(EditTask(updatedTask));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final dateText = _selectedDateRange != null 
        ? '${intl.DateFormat.MMMd().format(_selectedDateRange!.start)} - ${intl.DateFormat.MMMd().format(_selectedDateRange!.end)}'
        : 'Select Dates';

    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'New Task'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v!.isEmpty ? 'Title is required' : null,
                ),
                const Gap(16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                ),
                const Gap(16),
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Timeline',
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    child: Text(dateText),
                  ),
                ),
                const Gap(16),
                DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: TaskPriority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _priority = val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
