import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/features/tasks/data/models/task_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../task_provider.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  Map<String, String> _sharedUserNames = {};
  String? _createdByName;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _fetchUserNames();
  }

  Future<void> _fetchUserNames() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final allUserIds = {...?_task.sharedWith, _task.ownerId};
    final names = <String, String>{};

    for (final uid in allUserIds) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        names[uid] = data?['name'] ?? uid;
      }
    }

    setState(() {
      _sharedUserNames = names;
      _createdByName = (_task.ownerId == currentUserId) ? 'Me' : names[_task.ownerId] ?? _task.ownerId;
    });
  }

  Future<void> _shareTaskWithUser(String email) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        _showSnackBar('User not found');
        return;
      }

      final userIdToShare = userSnapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('tasks').doc(_task.id).update({
        'sharedWith': FieldValue.arrayUnion([userIdToShare]),
      });

      _showSnackBar('Task shared successfully');
    } catch (e) {
      _showSnackBar('Error sharing task: $e');
    }
  }

  Future<void> _deleteTask() async {
    try {
      await Provider.of<TaskProvider>(context, listen: false).deleteTask(_task.id);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error deleting task: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showShareDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Share Task', style: AppTextStyles.bodyLarge),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter email to share with'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final email = controller.text.trim();
              Navigator.pop(context);
              await _shareTaskWithUser(email);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task', style: AppTextStyles.bodyLarge),
        content: const Text('Are you sure you want to delete this task?', style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTask();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_task.title, style: AppTextStyles.heading1.copyWith(color: AppColors.textDark)),
        const SizedBox(height: 8),
        Text(
          _task.description?.isNotEmpty == true ? _task.description! : 'No description',
          style: AppTextStyles.buttonText.copyWith(color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildTaskMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          _task.dueDate != null
              ? 'Due: ${DateFormat('yyyy-MM-dd h:mm a').format(_task.dueDate!)}'
              : 'No due date',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Text('Priority: ${_task.priority}', style: AppTextStyles.bodyLarge),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Completed:', style: AppTextStyles.bodyLarge),
            Switch(
              value: _task.isCompleted,
              activeColor: AppColors.primary,
              onChanged: (value) async {
                await Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(_task);
                setState(() {
                  _task = _task.copyWith(isCompleted: value);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Created At: ${DateFormat('yyyy-MM-dd h:mm a').format(_task.createdAt)}',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_createdByName != null) ...[
          const SizedBox(height: 16),
          Text('Created By:', style: AppTextStyles.bodyLarge),
          Text(_createdByName!, style: AppTextStyles.bodyLarge),
        ],
        const SizedBox(height: 16),
        Text('Shared With:', style: AppTextStyles.bodyLarge),
        if ((_task.sharedWith?.isNotEmpty ?? false))
          ..._task.sharedWith!.map((uid) {
            final isMe = uid == FirebaseAuth.instance.currentUser?.uid;
            final name = isMe ? 'Me' : (_sharedUserNames[uid] ?? uid);
            return Text(name, style: AppTextStyles.bodyLarge);
          })
        else
          Text('Not shared with anyone.', style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Task Details',
          style: AppTextStyles.bodyLarge
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share, color: AppColors.primary,), onPressed: _showShareDialog),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary,),
            onPressed: () async {
              final updatedTask = await Navigator.push<Task>(
                context,
                MaterialPageRoute(builder: (_) => EditTaskScreen(task: _task)),
              );
              if (updatedTask != null) {
                setState(() => _task = updatedTask);
              }
            },
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red,), onPressed: _showDeleteConfirmationDialog),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeader(),
            _buildTaskMetadata(),
            _buildUserInfo(),
          ],
        ),
      ),
    );
  }
}
