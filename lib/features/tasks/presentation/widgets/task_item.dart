import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/features/tasks/data/models/task_model.dart';
import 'package:taskmenot/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:taskmenot/features/tasks/task_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        );
      },
      child: Card(
        color: AppColors.primaryLight,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => taskProvider.toggleTaskCompletion(task),
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: task.isCompleted ? Colors.grey : AppColors.textDark,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('EEE, MMM d • h:mm a').format(task.dueDate!),
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildPriorityChip(task.priority),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.redAccent;
        break;
      case 'medium':
        color = Colors.orangeAccent;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }
}
