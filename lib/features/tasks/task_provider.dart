import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:taskmenot/features/tasks/data/datasources/firestore_task_datasource.dart';
import 'package:taskmenot/features/tasks/data/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final FirestoreTaskDatasource _datasource;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskProvider({FirestoreTaskDatasource? datasource})
      : _datasource = datasource ?? FirestoreTaskDatasource();

  // Computed task views
  List<Task> get todaysTasks => _getTodaysTasks();
  List<Task> get upcomingTasks => _getUpcomingTasks();
  int get totalTaskCount => _tasks.length;
  int get completedTaskCount => _tasks.where((t) => t.isCompleted).length;
  int get upcomingTaskCount => upcomingTasks.length;
  int get sharedTaskCount => _tasks.where((t) => t.sharedWith.isNotEmpty).length;

  // Fetch tasks (initial or refresh)
  // Future<void> fetchTasks(String userId) async {
  //   try {
  //     final snapshot = await _datasource.getTasksOnce(userId);
  //     _tasks = snapshot;
  //     notifyListeners();
  //     print("Tasks updated for $userId: $_tasks");
  //   } catch (e) {
  //     debugPrint('Error fetching tasks: $e');
  //   }
  // }

  // Toggle completion
  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedStatus = !task.isCompleted;
      await _datasource.updateTask(task.id, {'isCompleted': updatedStatus});
      await fetchAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _datasource.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // Helpers
  List<Task> _getTodaysTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      final due = task.dueDate;
      return due != null &&
          DateTime(due.year, due.month, due.day) == today;
    }).toList();
  }

  List<Task> _getUpcomingTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate != null &&
          !task.isCompleted &&
          task.dueDate!.isAfter(now);
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  // Add task
  Future<void> addTask(Task task) async {
    await _datasource.addTask(task);
    await fetchAllTasks();
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      await _datasource.updateTask(task.id, {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate,
        'priority': task.priority,
      });
      await fetchAllTasks(); // Optionally refresh task list
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> fetchAllTasks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final ownTasksQuery = await FirebaseFirestore.instance
          .collection('tasks')
          .where('ownerId', isEqualTo: userId)
          .get();

      final sharedTasksQuery = await FirebaseFirestore.instance
          .collection('tasks')
          .where('sharedWith', arrayContains: userId)
          .get();

      final allDocs = {
        ...ownTasksQuery.docs,
        ...sharedTasksQuery.docs,
      };

      final tasks = allDocs.map((doc) {
        final data = doc.data();
        return Task.fromMap(data..['id'] = doc.id);
      }).toList();

      _tasks = tasks;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all tasks: $e');
    }
  }



  // Getter for the current user ID from Firebase Auth
  String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';  // Return the UID or an empty string if no user is logged in
  }
}
