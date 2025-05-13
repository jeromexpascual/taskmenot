import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/features/tasks/data/models/task_model.dart';
import 'package:taskmenot/features/tasks/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;

  String? _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDateController = TextEditingController(
      text: widget.task.dueDate?.toIso8601String().split('T').first ?? '',
    );
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (selectedDate != null) {
      _dueDateController.text = selectedDate.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        title: const Text('Edit Task', style: AppTextStyles.bodyLarge),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text('Title', style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text('Description', style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              style: AppTextStyles.bodyLarge,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Due Date
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text('Due Date', style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dueDateController,
              style: AppTextStyles.bodyLarge,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onPressed: _selectDate,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text('Priority', style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
              items: ['Low', 'Medium', 'High']
                  .map((priority) => DropdownMenuItem(
                value: priority,
                child: Text(priority),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final updatedTask = Task(
                    id: widget.task.id,
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    dueDate: DateTime.tryParse(_dueDateController.text),
                    priority: _priority ?? 'Low',
                    ownerId: widget.task.ownerId,
                    createdAt: widget.task.createdAt,
                  );

                  try {
                    await Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task updated successfully')),
                    );
                    Navigator.pop(context, updatedTask);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating task: $e')),
                    );
                  }

                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        )

      ),
    );
  }
}
