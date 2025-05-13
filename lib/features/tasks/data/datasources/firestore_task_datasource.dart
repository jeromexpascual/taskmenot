import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreTaskDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Add a new task
  Future<void> addTask(Task task) async {
    await _firestore.collection(_collection).add(task.toMap());
  }

  // Get tasks for the current user
  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromDoc(doc)).toList());
  }

  // Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await _firestore.collection(_collection).doc(taskId).update(updates);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collection).doc(taskId).delete();
  }

  Future<List<Task>> getTasksOnce(String userId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Task.fromDoc(doc))
        .toList();
  }

}
